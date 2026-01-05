#!/usr/bin/env bash
# PACKAGE: efibootmgr
# DESCRIPTION: EFI boot manager
# CATEGORY: core
# UBUNTU_PKG: apt\
# ARCH_PKG: efibootmgr
# NIX_PKG: pacman\:efibootmgr:nixpkgs.efibootmgr
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing efibootmgr..."

    # Skip if already installed
    if is_package_installed "efibootmgr"; then
        log "efibootmgr is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt\"
            ;;
        arch)
            install_package "efibootmgr"
            ;;
        nixos)
            log "For NixOS, add 'pacman\:efibootmgr:nixpkgs.efibootmgr' to environment.systemPackages in configuration.nix"
log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "efibootmgr installation complete"
}

main "$@"
