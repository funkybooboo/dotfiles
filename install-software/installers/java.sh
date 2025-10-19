#!/usr/bin/env bash
set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/log.sh"

log "Install Java"

install_java() {
    # Check if the plugin is already installed
    if ! asdf plugin list | grep -q '^java$'; then
        log "Adding Java plugin to asdf..."
        asdf plugin add java https://github.com/halcyon/asdf-java.git
    else
        log "Java plugin already installed, skipping..."
    fi

    TARGET_VERSION="temurin-25.0.0+36.0.LTS"
    asdf install java "$TARGET_VERSION"
    asdf set -u java "$TARGET_VERSION"
}

install_java
