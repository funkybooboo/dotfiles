#!/usr/bin/env bash
# PACKAGE: swig
# DESCRIPTION: Package from APT repository
# CATEGORY: core
# UBUNTU_PKG: apt:swig
# ARCH_PKG: pacman:swig
# NIX_PKG: nixpkgs.swig
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing swig..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "swig"; then
                log "swig is already installed"
                return 0
            fi
            install_package "apt:swig"
            ;;
        arch)
            if is_package_installed "swig"; then
                log "swig is already installed"
                return 0
            fi
            install_package "pacman:swig"
            ;;
        nixos)
            log "For NixOS, add 'swig' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "swig installation complete"
}

main "$@"
