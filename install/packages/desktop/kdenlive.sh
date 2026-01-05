#!/usr/bin/env bash
# PACKAGE: kdenlive
# DESCRIPTION: Open-source video editor
# CATEGORY: desktop
# UBUNTU_PKG: apt:kdenlive
# ARCH_PKG: pacman:kdenlive
# NIX_PKG: nixpkgs.kdenlive
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing kdenlive..."

    # Skip if already installed
    if is_package_installed "kdenlive"; then
        log "kdenlive is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt:kdenlive"
            ;;
        arch)
            install_package "pacman:kdenlive"
            ;;
        nixos)
            log "For NixOS, add 'kdenlive' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "kdenlive installation complete"
}

main "$@"
