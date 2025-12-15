#!/usr/bin/env bash
# Post-Reboot Installer - User-level applications

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_DIR="$(cd "$SCRIPT_DIR/../packages" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/log.sh"

check_supported_distro || exit 1

SEPARATOR="=============================================================="

# Categories for post-reboot installation
POST_REBOOT_CATEGORIES=(
    "core"
    "dev"
    "desktop"
    "special"  # Excludes package-managers, basic-system, cuda, container-runtime
    "fonts"
)

# Packages to skip in special/ (already installed in pre-reboot)
SKIP_PACKAGES=(
    "package-managers.sh"
    "basic-system.sh"
    "cuda.sh"
    "container-runtime.sh"
)

FAILED_PACKAGES=()
SUCCESSFUL_PACKAGES=()

should_skip_package() {
    local pkg_file="$1"
    local pkg_name=$(basename "$pkg_file")

    for skip in "${SKIP_PACKAGES[@]}"; do
        if [ "$pkg_name" = "$skip" ]; then
            return 0  # Should skip
        fi
    done
    return 1  # Should not skip
}

install_package_file() {
    local pkg_file="$1"
    local pkg_name=$(basename "$pkg_file" .sh)

    echo ""
    echo "${SEPARATOR}"
    log "Installing $pkg_name..."
    echo "${SEPARATOR}"

    if bash "$pkg_file"; then
        log "✓ $pkg_name installed successfully"
        SUCCESSFUL_PACKAGES+=("$pkg_name")
        return 0
    else
        log "✗ $pkg_name installation failed"
        FAILED_PACKAGES+=("$pkg_name")
        return 1
    fi
}

main() {
    log "============================================"
    log "Post-Reboot Installation ($DISTRO_NAME)"
    log "============================================"
    log "Installing user-level packages..."
    log ""

    # Install packages by category
    for category in "${POST_REBOOT_CATEGORIES[@]}"; do
        if [ -d "$PACKAGES_DIR/$category" ]; then
            log ""
            log "=========================================="
            log "Installing $category packages..."
            log "=========================================="

            for pkg_file in "$PACKAGES_DIR/$category"/*.sh; do
                [ -f "$pkg_file" ] || continue

                # Skip pre-reboot packages if in special/
                if [ "$category" = "special" ] && should_skip_package "$pkg_file"; then
                    log "Skipping $(basename "$pkg_file" .sh) (already installed in pre-reboot)"
                    continue
                fi

                install_package_file "$pkg_file" || true
            done
        else
            log "WARNING: Category $category not found, skipping"
        fi
    done

    # Report results
    echo ""
    echo ""
    log "============================================"
    log "     Post-Reboot Installation Summary"
    log "============================================"
    log "Distribution: $DISTRO_NAME"
    log ""

    if [ ${#SUCCESSFUL_PACKAGES[@]} -gt 0 ]; then
        log "✓ Successfully installed: ${#SUCCESSFUL_PACKAGES[@]} package(s)"
    fi

    if [ ${#FAILED_PACKAGES[@]} -eq 0 ]; then
        log ""
        log "✓✓✓ ALL PACKAGES INSTALLED SUCCESSFULLY! ✓✓✓"
    else
        log ""
        log "✗ Failed to install: ${#FAILED_PACKAGES[@]} package(s)"
        log "Failed packages:"
        for pkg in "${FAILED_PACKAGES[@]}"; do
            log "  - $pkg"
        done
    fi

    log ""
    log "============================================"
    log "Post-Reboot Installation Complete!"
    log "============================================"
}

main "$@"
