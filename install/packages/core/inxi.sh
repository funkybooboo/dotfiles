#!/usr/bin/env bash
# PACKAGE: inxi
# DESCRIPTION: Full featured CLI system information tool
# CATEGORY: core
# UBUNTU_PKG: apt\
# ARCH_PKG: inxi
# NIX_PKG: pacman\:inxi:nixpkgs.inxi
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing inxi..."

    # Skip if already installed
    if is_package_installed "inxi"; then
        log "inxi is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt\"
            ;;
        arch)
            install_package "inxi"
            ;;
        nixos)
            log "For NixOS, add 'pacman\:inxi:nixpkgs.inxi' to environment.systemPackages in configuration.nix"
log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "inxi installation complete"
}

main "$@"
