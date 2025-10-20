#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/log.sh"
source "$SCRIPT_DIR/../packages/packages.sh"

# ===============================
# Helper Functions
# ===============================

install_apt_pkg() {
  local pkg=$1
  if ! dpkg -s "$pkg" &>/dev/null; then
    log "Installing $pkg via APT..."
    sudo apt install -y "$pkg" || log "WARNING: Failed to install $pkg"
  else
    log "$pkg already installed (APT)."
  fi
}

install_flatpak_pkg() {
  local pkg=$1
  if ! flatpak list | grep -q "$pkg"; then
    log "Installing $pkg via Flatpak..."
    sudo flatpak install -y flathub "$pkg" || log "WARNING: Failed to install $pkg"
  else
    log "$pkg already installed (Flatpak)."
  fi
}

install_snap_pkg() {
  local pkg=$1
  if ! snap list | grep -q "^$pkg[[:space:]]"; then
    log "Installing $pkg via Snap..."
    sudo snap install "$pkg" || log "WARNING: Failed to install $pkg"
  else
    log "$pkg already installed (Snap)."
  fi
}

install_snap_classic_pkg() {
  local pkg=$1
  if ! snap list | grep -q "^$pkg[[:space:]]"; then
    log "Installing $pkg via Snap (classic)..."
    sudo snap install "$pkg" --classic || log "WARNING: Failed to install $pkg"
  else
    log "$pkg already installed (Snap classic)."
  fi
}

install_nix_pkg() {
  local pkg=$1
  if ! nix-env -q | grep -qw "$pkg"; then
    log "Installing $pkg via nix-env..."
    nix-env -iA "nixpkgs.$pkg" || log "WARNING: Failed to install $pkg"
  else
    log "$pkg already installed (nix-env)."
  fi
}

install_pacstall_pkg() {
  local pkg=$1
  if ! pacstall --list | grep -q "^$pkg\$"; then
    log "Installing $pkg via Pacstall..."
    pacstall --install "$pkg" || log "WARNING: Failed to install $pkg"
  else
    log "$pkg already installed (Pacstall)."
  fi
}

install_brew_pkg() {
  local pkg=$1
  if ! brew list "$pkg" &>/dev/null; then
    log "Installing $pkg via Homebrew..."
    brew install "$pkg" || log "WARNING: Failed to install $pkg"
  else
    log "$pkg already installed (Homebrew)."
  fi
}

install_pip_pkg() {
  local pkg=$1
  if ! pip3 show "$pkg" &>/dev/null; then
    log "Installing Python package $pkg..."
    pip3 install --user "$pkg" || log "WARNING: Failed to install Python package $pkg"
  else
    log "Python package $pkg already installed."
  fi
}

install_npm_pkg() {
  local pkg=$1
  if ! npm list -g --depth=0 | grep -q "^$pkg@"; then
    log "Installing npm package $pkg globally..."
    npm install -g "$pkg" || log "WARNING: Failed to install npm package $pkg"
  else
    log "npm package $pkg already installed globally."
  fi
}

# ===============================
# Install Packages
# ===============================

for pkg in "${APT_PACKAGES[@]:-}"; do
  install_apt_pkg "$pkg"
done

for pkg in "${FLATPAK_PACKAGES[@]:-}"; do
  install_flatpak_pkg "$pkg"
done

for pkg in "${SNAP_PACKAGES[@]:-}"; do
  install_snap_pkg "$pkg"
done

for pkg in "${SNAP_CLASSIC_PACKAGES[@]:-}"; do
  install_snap_classic_pkg "$pkg"
done

for pkg in "${NIX_PACKAGES[@]:-}"; do
  install_nix_pkg "$pkg"
done

for pkg in "${PACSTALL_PACKAGES[@]:-}"; do
  install_pacstall_pkg "$pkg"
done

for pkg in "${HOMEBREW_PACKAGES[@]:-}"; do
  install_brew_pkg "$pkg"
done

for pkg in "${PIP_PACKAGES[@]:-}"; do
  install_pip_pkg "$pkg"
done

for pkg in "${NPM_PACKAGES[@]:-}"; do
  install_npm_pkg "$pkg"
done

log "All packages installation complete!"
