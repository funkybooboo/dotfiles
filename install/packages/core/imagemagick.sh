#!/usr/bin/env bash
# PACKAGE: imagemagick
# DESCRIPTION: Image manipulation tools
# CATEGORY: core
# UBUNTU_PKG: apt:imagemagick
# ARCH_PKG: pacman:imagemagick
# NIX_PKG: nixpkgs.imagemagick
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing imagemagick..."

    # Skip if already installed
    if is_package_installed "imagemagick"; then
        log "imagemagick is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt:imagemagick"
            ;;
        arch)
            install_package "pacman:imagemagick"
            ;;
        nixos)
            log "For NixOS, add 'imagemagick' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "imagemagick installation complete"
}

main "$@"
