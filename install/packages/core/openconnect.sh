#!/usr/bin/env bash
# PACKAGE: openconnect
# DESCRIPTION: Package from APT repository
# CATEGORY: core
# UBUNTU_PKG: apt:openconnect
# ARCH_PKG: pacman:openconnect
# NIX_PKG: nixpkgs.openconnect
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing openconnect..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "openconnect"; then
                log "openconnect is already installed"
                return 0
            fi
            install_package "apt:openconnect"
            ;;
        arch)
            if is_package_installed "openconnect"; then
                log "openconnect is already installed"
                return 0
            fi
            install_package "pacman:openconnect"
            ;;
        nixos)
            log "For NixOS, add 'openconnect' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "openconnect installation complete"
}

main "$@"
