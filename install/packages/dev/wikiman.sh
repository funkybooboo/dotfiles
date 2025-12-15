#!/usr/bin/env bash
# PACKAGE: wikiman
# DESCRIPTION: Package from Nix repository
# CATEGORY: dev
# UBUNTU_PKG: nix:wikiman
# ARCH_PKG: pacman:wikiman
# NIX_PKG: nixpkgs.wikiman
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing wikiman..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "wikiman"; then
                log "wikiman is already installed"
                return 0
            fi
            install_package "nix:wikiman"
            ;;
        arch)
            if is_package_installed "wikiman"; then
                log "wikiman is already installed"
                return 0
            fi
            install_package "pacman:wikiman"
            ;;
        nixos)
            log "For NixOS, add 'wikiman' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "wikiman installation complete"
}

main "$@"
