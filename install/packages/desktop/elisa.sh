#!/usr/bin/env bash
# PACKAGE: elisa
# DESCRIPTION: Package from Snap store
# CATEGORY: desktop
# UBUNTU_PKG: snap:elisa
# ARCH_PKG: pacman:elisa
# NIX_PKG: nixpkgs.elisa
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing elisa..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "elisa"; then
                log "elisa is already installed"
                return 0
            fi
            install_package "snap:elisa"
            ;;
        arch)
            if is_package_installed "elisa"; then
                log "elisa is already installed"
                return 0
            fi
            install_package "pacman:elisa"
            ;;
        nixos)
            log "For NixOS, add 'elisa' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "elisa installation complete"
}

main "$@"
