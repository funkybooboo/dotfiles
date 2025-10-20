#!/usr/bin/env bash

set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/log.sh"

install_lazyvim() {
  log "Installing LazyVim..."

  mv ~/.config/nvim{,.bak}
  mv ~/.local/share/nvim{,.bak}
  mv ~/.local/state/nvim{,.bak}
  mv ~/.cache/nvim{,.bak}

  git clone https://github.com/LazyVim/starter ~/.config/nvim

  rm -rf ~/.config/nvim/.git
}

install_lazyvim
