#!/usr/bin/env bash
set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/log.sh"

install_jetbrains_toolbox() {
    TMP_DIR="/tmp"
    INSTALL_DIR="$HOME/.local/share/JetBrains/Toolbox"
    SYMLINK_DIR="$HOME/.local/bin"

    log "Fetching latest release URL..."
    ARCHIVE_URL=$(curl -s 'https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release' \
                  | grep -Po '"linux":.*?[^\\]",' \
                  | awk -F ':' '{print $3 ":" $4}' \
                  | sed 's/[", ]//g')
    if [[ -z "$ARCHIVE_URL" ]]; then
        log "Error: Could not fetch latest JetBrains Toolbox release"
        return 1
    fi
    ARCHIVE_FILENAME=$(basename "$ARCHIVE_URL")

    # Download idempotently
    if [[ -f "$TMP_DIR/$ARCHIVE_FILENAME" ]]; then
        log "$ARCHIVE_FILENAME already downloaded. Skipping download."
    else
        log "Downloading $ARCHIVE_FILENAME..."
        wget -q -cO "$TMP_DIR/$ARCHIVE_FILENAME" "$ARCHIVE_URL"
    fi

    # Extract idempotently
    log "Extracting to $INSTALL_DIR..."
    mkdir -p "$INSTALL_DIR"
    rm -rf "$INSTALL_DIR"/*
    tar -xzf "$TMP_DIR/$ARCHIVE_FILENAME" -C "$INSTALL_DIR" --strip-components=1
    chmod +x "$INSTALL_DIR/bin/jetbrains-toolbox"

    # Create symlink
    log "Creating symlink in $SYMLINK_DIR..."
    mkdir -p "$SYMLINK_DIR"
    ln -sfn "$INSTALL_DIR/bin/jetbrains-toolbox" "$SYMLINK_DIR/jetbrains-toolbox"

    # Launch Toolbox if not running
    if ! pgrep -f "jetbrains-toolbox" >/dev/null; then
        log "Launching JetBrains Toolbox..."
        nohup "$INSTALL_DIR/bin/jetbrains-toolbox" >/dev/null 2>&1 &
    else
        log "JetBrains Toolbox is already running. Skipping launch."
    fi

    log "JetBrains Toolbox installed successfully. Run via 'jetbrains-toolbox' command."
}

install_jetbrains_toolbox
