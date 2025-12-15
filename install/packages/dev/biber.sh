#!/usr/bin/env bash
# PACKAGE: biber
# DESCRIPTION: Package from Nix repository
# CATEGORY: dev
# UBUNTU_PKG: nix:biber
# ARCH_PKG: pacman:biber
# NIX_PKG: nixpkgs.biber
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing biber..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "biber"; then
                log "biber is already installed"
                return 0
            fi
            install_package "nix:biber"
            ;;
        arch)
            if is_package_installed "biber"; then
                log "biber is already installed"
                return 0
            fi
            install_package "pacman:biber"
            ;;
        nixos)
            log "For NixOS, add 'biber' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "biber installation complete"
}

main "$@"
