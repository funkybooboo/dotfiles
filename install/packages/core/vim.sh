#!/usr/bin/env bash
# PACKAGE: vim
# DESCRIPTION: Highly configurable text editor
# CATEGORY: core
# UBUNTU_PKG: apt:vim
# ARCH_PKG: pacman:vim
# NIX_PKG: nixpkgs.vim
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing vim..."

    # Skip if already installed
    if is_package_installed "vim"; then
        log "vim is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt:vim"
            ;;
        arch)
            install_package "pacman:vim"
            ;;
        nixos)
            log "For NixOS, add 'vim' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "vim installation complete"
}

main "$@"
