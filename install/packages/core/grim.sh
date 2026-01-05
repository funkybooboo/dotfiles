#!/usr/bin/env bash
# PACKAGE: grim
# DESCRIPTION: Screenshot utility for Wayland
# CATEGORY: core
# UBUNTU_PKG: apt:grim
# ARCH_PKG: pacman:grim
# NIX_PKG: nixpkgs.grim
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing grim..."

    # Skip if already installed
    if is_package_installed "grim"; then
        log "grim is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt:grim"
            ;;
        arch)
            install_package "pacman:grim"
            ;;
        nixos)
            log "For NixOS, add 'grim' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "grim installation complete"
}

main "$@"
