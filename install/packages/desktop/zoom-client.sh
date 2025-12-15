#!/usr/bin/env bash
# PACKAGE: zoom-client
# DESCRIPTION: Package from Snap store
# CATEGORY: desktop
# UBUNTU_PKG: snap:zoom-client
# ARCH_PKG: pacman:zoom-client
# NIX_PKG: nixpkgs.zoom-client
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing zoom-client..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "zoom-client"; then
                log "zoom-client is already installed"
                return 0
            fi
            install_package "snap:zoom-client"
            ;;
        arch)
            if is_package_installed "zoom-client"; then
                log "zoom-client is already installed"
                return 0
            fi
            install_package "pacman:zoom-client"
            ;;
        nixos)
            log "For NixOS, add 'zoom-client' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "zoom-client installation complete"
}

main "$@"
