#!/usr/bin/env bash
#
# manage-packages.sh
# Script to manage package lists inside packages.sh
#

set -euo pipefail
IFS=$'\n\t'

PKG_FILE="./packages.sh"

usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

Options:
  --check-for-duplicates, -cfd
        Check for duplicates across all package lists.

  --add-pkg <LIST_NAME> <PACKAGE_NAME>, -ap <LIST_NAME> <PACKAGE_NAME>
        Add PACKAGE_NAME to the package list named LIST_NAME if not already present.

  --remove-pkg <LIST_NAME> <PACKAGE_NAME>, -rp <LIST_NAME> <PACKAGE_NAME>
        Remove PACKAGE_NAME from the package list named LIST_NAME if it exists.

  --help, -h
        Show this help message.

Examples:
  $0 --check-for-duplicates
  $0 --add-pkg APT_PACKAGES curl
  $0 -ap SNAP_PACKAGES hello-world
  $0 --remove-pkg APT_PACKAGES curl
  $0 -rp SNAP_PACKAGES hello-world
EOF
    exit 1
}

if [[ ! -f "$PKG_FILE" ]]; then
    echo "ERROR: $PKG_FILE not found!"
    exit 1
fi

get_array_content() {
    local array_name=$1
    sed -n "/^${array_name}=/,/^)/p" "$PKG_FILE" | sed '1d;$d' | sed 's/#.*//' | sed '/^\s*$/d' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

replace_array_content() {
    local array_name=$1
    shift
    local new_content=("$@")
    awk -v arr="$array_name" -v n="${#new_content[@]}" -v repl="$(printf "%s\n" "${new_content[@]}")" '
    BEGIN { inside=0 }
    {
        if ($0 ~ "^"arr"=\\(") {
            print $0
            inside=1
            for (i=0; i<n; i++) {
                print "    " repl[i]
            }
            next
        }
        if (inside && $0 ~ "^\\)") {
            print $0
            inside=0
            next
        }
        if (!inside) print $0
    }
    ' "$PKG_FILE" > "${PKG_FILE}.tmp" && mv "${PKG_FILE}.tmp" "$PKG_FILE"
}

check_duplicates() {
    local all_pkgs=()
    local duplicates=()
    local -A seen=()

    local arrays
    arrays=$(grep -Po '^[A-Z_]+PACKAGES=' "$PKG_FILE" | cut -d= -f1)

    for arr in $arrays; do
        while read -r pkg; do
            all_pkgs+=("$pkg")
        done < <(get_array_content "$arr")
    done

    for pkg in "${all_pkgs[@]}"; do
        if [[ -n "${seen[$pkg]:-}" ]]; then
            duplicates+=("$pkg")
        else
            seen[$pkg]=1
        fi
    done

    if (( ${#duplicates[@]} > 0 )); then
        echo "Duplicates found across package lists:"
        for d in "${duplicates[@]}"; do
            echo "  $d"
        done
        return 1
    else
        echo "No duplicates found across package lists."
        return 0
    fi
}

add_package() {
    local list_name=$1
    local pkg_name=$2

    if ! grep -q "^${list_name}=" "$PKG_FILE"; then
        echo "ERROR: Package list '$list_name' does not exist in $PKG_FILE"
        exit 1
    fi

    mapfile -t current_pkgs < <(get_array_content "$list_name")

    for p in "${current_pkgs[@]}"; do
        if [[ "$p" == "$pkg_name" ]]; then
            echo "Package '$pkg_name' already exists in $list_name"
            return 0
        fi
    done

    current_pkgs+=("$pkg_name")
    replace_array_content "$list_name" "${current_pkgs[@]}"
    echo "Package '$pkg_name' added to $list_name"
}

remove_package() {
    local list_name=$1
    local pkg_name=$2

    if ! grep -q "^${list_name}=" "$PKG_FILE"; then
        echo "ERROR: Package list '$list_name' does not exist in $PKG_FILE"
        exit 1
    fi

    mapfile -t current_pkgs < <(get_array_content "$list_name")

    local found=0
    local new_pkgs=()

    for p in "${current_pkgs[@]}"; do
        if [[ "$p" == "$pkg_name" ]]; then
            found=1
            continue
        fi
        new_pkgs+=("$p")
    done

    if (( found == 0 )); then
        echo "Package '$pkg_name' not found in $list_name"
        return 0
    fi

    replace_array_content "$list_name" "${new_pkgs[@]}"
    echo "Package '$pkg_name' removed from $list_name"
}

if (( $# == 0 )); then
    usage
fi

case "$1" in
    --check-for-duplicates|-cfd)
        check_duplicates
        ;;

    --add-pkg|-ap)
        if (( $# != 3 )); then
            echo "ERROR: $1 requires exactly two arguments."
            usage
        fi
        add_package "$2" "$3"
        ;;

    --remove-pkg|-rp)
        if (( $# != 3 )); then
            echo "ERROR: $1 requires exactly two arguments."
            usage
        fi
        remove_package "$2" "$3"
        ;;

    --help|-h)
        usage
        ;;

    *)
        echo "Unknown option: $1"
        usage
        ;;
esac
