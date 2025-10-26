#!/usr/bin/env bash
set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/log.sh"

log "Install Openconnect"

install_openconnect() {
  log "Installing Openconnect..."
  sudo add-apt-repository ppa:yuezk/globalprotect-openconnect
  sudo apt-get install globalprotect-openconnect
  log "Openconnect Installed."
}

install_openconnect
