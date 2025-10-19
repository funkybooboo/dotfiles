#!/usr/bin/env bash

set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/log.sh"  # provides `log` function

install_signal_desktop() {
  # 1. Install official public software signing key if not already installed
  local KEYRING="/usr/share/keyrings/signal-desktop-keyring.gpg"
  if [ ! -f "$KEYRING" ]; then
    wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor >signal-desktop-keyring.gpg
    sudo tee "$KEYRING" <signal-desktop-keyring.gpg >/dev/null
    rm signal-desktop-keyring.gpg
    log "Signal key installed."
  else
    log "Signal key already exists. Skipping."
  fi

  # 2. Add repository if not already added
  local SOURCES_LIST="/etc/apt/sources.list.d/signal-desktop.sources"
  if [ ! -f "$SOURCES_LIST" ]; then
    wget -O signal-desktop.sources https://updates.signal.org/static/desktop/apt/signal-desktop.sources
    sudo tee "$SOURCES_LIST" <signal-desktop.sources >/dev/null
    rm signal-desktop.sources
    log "Signal repository added."
  else
    log "Signal repository already exists. Skipping."
  fi

  # 3. Update and install Signal if not already installed
  if ! dpkg -l | grep -qw signal-desktop; then
    log "Installing Signal Desktop..."
    sudo apt update
    sudo apt install -y signal-desktop
    log "Signal Desktop installed successfully."
  else
    log "Signal Desktop is already installed. Skipping."
  fi
}

install_signal_desktop
