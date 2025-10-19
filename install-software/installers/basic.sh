#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/log.sh"

log "Ensure we have basic tools installed"
sudo apt install -y software-properties-common curl wget git sudo ca-certificates gnupg lsb-release apt-transport-https build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget libbz2-dev
