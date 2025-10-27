#!/usr/bin/env bash

set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/log.sh"

install_github_desktop() {
    log "Installing GitHub Desktop..."

    local original_dir
    original_dir=$(pwd)
    cd /tmp || { log "Error: Cannot access /tmp directory"; return 1; }

    log "Fetching latest GitHub Desktop release info..."

    local download_url
    if command -v jq &>/dev/null; then
        log "Using jq for JSON parsing..."
        download_url=$(curl -s https://api.github.com/repos/shiftkey/desktop/releases/latest | \
                       jq -r '.assets[] | select(.name | contains("linux-amd64") and endswith(".deb")) | .browser_download_url' | head -1)
    else
        log "jq not found, using grep/sed for JSON parsing..."
        local release_info
        if ! release_info=$(curl -s https://api.github.com/repos/shiftkey/desktop/releases/latest); then
            log "Error: Failed to fetch release information"
            cd "$original_dir"
            return 1
        fi
        download_url=$(echo "$release_info" | grep -o '"browser_download_url":[[:space:]]*"[^"]*linux-amd64[^"]*\.deb"' | head -1 | sed 's/.*"browser_download_url":[[:space:]]*"\([^"]*\)".*/\1/')
    fi

    if [ -z "$download_url" ]; then
        log "Error: Could not find Linux amd64 deb package in latest release"
        cd "$original_dir"
        return 1
    fi

    local deb_file
    deb_file=$(basename "$download_url")
    log "Latest version: $deb_file"

    # Reuse existing file if less than 1 day old
    if [ -f "$deb_file" ] && [ $(($(date +%s) - $(stat -c %Y "$deb_file"))) -lt 86400 ]; then
        log "Using existing GitHub Desktop package..."
    else
        log "Downloading GitHub Desktop..."
        rm -f GitHubDesktop*.deb
        if ! wget -q --show-progress "$download_url"; then
            log "Error: Failed to download GitHub Desktop"
            cd "$original_dir"
            return 1
        fi
    fi

    log "Installing GitHub Desktop..."
    if sudo apt install -y ./"$deb_file"; then
        log "GitHub Desktop installed successfully"
        rm -f "$deb_file"
        cd "$original_dir"
        return 0
    else
        log "Error: Failed to install GitHub Desktop"
        cd "$original_dir"
        return 1
    fi
}

install_github_desktop
