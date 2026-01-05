#!/usr/bin/env bash
# PACKAGE: wl-clipboard
# DESCRIPTION: Command-line copy/paste utilities for Wayland
# CATEGORY: core
# UBUNTU_PKG: apt:wl-clipboard
# ARCH_PKG: pacman:wl-clipboard
# NIX_PKG: nixpkgs.wl-clipboard
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing wl-clipboard..."

    # Skip if already installed
    if is_package_installed "wl-clipboard"; then
        log "wl-clipboard is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt:wl-clipboard"
            ;;
        arch)
            install_package "pacman:wl-clipboard"
            ;;
        nixos)
            log "For NixOS, add 'wl-clipboard' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "wl-clipboard installation complete"
}

main "$@"
