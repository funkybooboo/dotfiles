#!/usr/bin/env bash
# PACKAGE: yazi
# DESCRIPTION: Package from Snap store (classic confinement)
# CATEGORY: dev
# UBUNTU_PKG: snap-classic:yazi
# ARCH_PKG: pacman:yazi
# NIX_PKG: nixpkgs.yazi
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing yazi..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "yazi"; then
                log "yazi is already installed"
                return 0
            fi
            install_package "snap-classic:yazi"
            ;;
        arch)
            if is_package_installed "yazi"; then
                log "yazi is already installed"
                return 0
            fi
            install_package "pacman:yazi"
            ;;
        nixos)
            log "For NixOS, add 'yazi' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "yazi installation complete"
}

main "$@"
