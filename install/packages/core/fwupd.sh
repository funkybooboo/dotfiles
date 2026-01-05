#!/usr/bin/env bash
# PACKAGE: fwupd
# DESCRIPTION: Firmware update daemon
# CATEGORY: core
# UBUNTU_PKG: apt\
# ARCH_PKG: fwupd
# NIX_PKG: pacman\:fwupd:nixpkgs.fwupd
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing fwupd..."

    # Skip if already installed
    if is_package_installed "fwupd"; then
        log "fwupd is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt\"
            ;;
        arch)
            install_package "fwupd"
            ;;
        nixos)
            log "For NixOS, add 'pacman\:fwupd:nixpkgs.fwupd' to environment.systemPackages in configuration.nix"
log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "fwupd installation complete"
}

main "$@"
