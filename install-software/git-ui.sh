#!/usr/bin/env bash

set -e
set -o pipefail

install_lazygit() {
    echo "Installing lazygit..."
    # Check if available in apt repository
    if apt-cache show lazygit &> /dev/null; then
        if sudo apt install -y lazygit; then
            echo "lazygit installed successfully via apt"
        else
            echo "Error: Failed to install lazygit via apt"
            return 1
        fi
    else
        echo "lazygit not available in apt repository, installing via alternative method..."
        # Alternative installation method (GitHub releases)
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        if [ -z "$LAZYGIT_VERSION" ]; then
            echo "Error: Could not determine latest lazygit version"
            return 1
        fi
        cd /tmp || return 1
        curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf lazygit.tar.gz lazygit
        sudo install lazygit /usr/local/bin
        rm lazygit.tar.gz lazygit
        echo "lazygit installed successfully"
    fi
}

install_github_desktop() {
    echo "Installing GitHub Desktop..."

    local original_dir=$(pwd)
    cd /tmp || { echo "Error: Cannot access /tmp directory"; return 1; }

    echo "Fetching latest GitHub Desktop release info..."

    # Check if jq is available for better JSON parsing
    if command -v jq >/dev/null 2>&1; then
        echo "Using jq for JSON parsing..."
        local download_url
        download_url=$(curl -s https://api.github.com/repos/shiftkey/desktop/releases/latest | \
                      jq -r '.assets[] | select(.name | contains("linux-amd64") and endswith(".deb")) | .browser_download_url' | head -1)
    else
        echo "jq not found, using grep/sed for JSON parsing..."
        local release_info
        if ! release_info=$(curl -s https://api.github.com/repos/shiftkey/desktop/releases/latest); then
            echo "Error: Failed to fetch release information"
            cd "$original_dir"
            return 1
        fi

        local download_url
        download_url=$(echo "$release_info" | grep -o '"browser_download_url":[[:space:]]*"[^"]*linux-amd64[^"]*\.deb"' | head -1 | sed 's/.*"browser_download_url":[[:space:]]*"\([^"]*\)".*/\1/')
    fi

    if [ -z "$download_url" ]; then
        echo "Error: Could not find Linux amd64 deb package in latest release"
        cd "$original_dir"
        return 1
    fi

    local deb_file
    deb_file=$(basename "$download_url")

    echo "Latest version: $deb_file"

    # Check if file already exists and is recent (less than 1 day old)
    if [ -f "$deb_file" ] && [ $(($(date +%s) - $(stat -c %Y "$deb_file"))) -lt 86400 ]; then
        echo "Using existing GitHub Desktop package..."
    else
        echo "Downloading GitHub Desktop..."
        rm -f GitHubDesktop*.deb

        if ! wget -q --show-progress "$download_url"; then
            echo "Error: Failed to download GitHub Desktop"
            cd "$original_dir"
            return 1
        fi
    fi

    echo "Installing GitHub Desktop package..."
    if sudo apt install -y ./"$deb_file"; then
        echo "GitHub Desktop installed successfully"
        rm -f "$deb_file"
        cd "$original_dir"
        return 0
    else
        echo "Error: Failed to install GitHub Desktop"
        cd "$original_dir"
        return 1
    fi
}

echo "Install git UI"
read -rp "(l)azygit or (g)ithub desktop or (b)oth or (n)one [b]: " git_ui
case $git_ui in
    l|L)
        install_lazygit
        ;;
    g|G)
        install_github_desktop
        ;;
    n|N)
        echo "No git UI installation requested"
        ;;
    *)
        install_lazygit
        install_github_desktop
        ;;
esac
