#!/usr/bin/env bash
# PACKAGE: iwd
# DESCRIPTION: Wireless daemon
# CATEGORY: core
# UBUNTU_PKG: apt\
# ARCH_PKG: iwd
# NIX_PKG: pacman\:iwd:nixpkgs.iwd
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing iwd..."

    # Skip if already installed
    if is_package_installed "iwd"; then
        log "iwd is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt\"
            ;;
        arch)
            install_package "iwd"
            ;;
        nixos)
            log "For NixOS, add 'pacman\:iwd:nixpkgs.iwd' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "iwd installation complete"
}

main "$@"
