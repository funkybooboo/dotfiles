#!/usr/bin/env bash
# PACKAGE: typst
# DESCRIPTION: Package from Snap store
# CATEGORY: desktop
# UBUNTU_PKG: snap:typst
# ARCH_PKG: pacman:typst
# NIX_PKG: nixpkgs.typst
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing typst..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "typst"; then
                log "typst is already installed"
                return 0
            fi
            install_package "snap:typst"
            ;;
        arch)
            if is_package_installed "typst"; then
                log "typst is already installed"
                return 0
            fi
            install_package "pacman:typst"
            ;;
        nixos)
            log "For NixOS, add 'typst' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "typst installation complete"
}

main "$@"
