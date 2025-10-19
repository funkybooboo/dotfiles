#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/log.sh"  # provides `log` function

log "Installing GlobalProtect OpenConnect ..."

sudo add-apt-repository ppa:yuezk/globalprotect-openconnect
sudo apt update
sudo apt-get install globalprotect-openconnect

log "GlobalProtect OpenConnect is installed!"
