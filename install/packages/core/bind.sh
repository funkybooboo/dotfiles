#!/usr/bin/env bash
# PACKAGE: bind
# DESCRIPTION: DNS server and utilities
# CATEGORY: core
# UBUNTU_PKG: apt\
# ARCH_PKG: bind9
# NIX_PKG: pacman\:bind:nixpkgs.bind
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing bind..."

    # Skip if already installed
    if is_package_installed "bind"; then
        log "bind is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt\"
            ;;
        arch)
            install_package "bind9"
            ;;
        nixos)
            log "For NixOS, add 'pacman\:bind:nixpkgs.bind' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "bind installation complete"
}

main "$@"
