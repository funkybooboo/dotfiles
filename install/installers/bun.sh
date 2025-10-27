#!/usr/bin/env bash
set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/log.sh"
source "$SCRIPT_DIR/../utils/shell-configs.sh"

log "Install Bun"

install_bun() {
    # Check if Bun is already installed
    if command -v bun &>/dev/null; then
        CURRENT_VERSION=$(bun --version)
        log "Bun is already installed (version $CURRENT_VERSION)"
        read -p "Do you want to reinstall/upgrade Bun? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log "Skipping Bun installation"
            return 0
        fi
    fi

    log "Installing Bun..."
    curl -fsSL https://bun.sh/install | bash

    # Add Bun to PATH for both bash and fish
    add_path_bash_and_fish "$HOME/.bun/bin"

    # Export for current session
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"

    # Verify installation
    if command -v bun &>/dev/null; then
        INSTALLED_VERSION=$(bun --version)
        log "Bun successfully installed (version $INSTALLED_VERSION)"
    else
        log "ERROR: Bun installation failed"
        return 1
    fi
}

install_bun
