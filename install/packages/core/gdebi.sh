#!/usr/bin/env bash
# PACKAGE: gdebi
# DESCRIPTION: Package from APT repository
# CATEGORY: core
# UBUNTU_PKG: apt:gdebi
# ARCH_PKG: pacman:gdebi
# NIX_PKG: nixpkgs.gdebi
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing gdebi..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "gdebi"; then
                log "gdebi is already installed"
                return 0
            fi
            install_package "apt:gdebi"
            ;;
        arch)
            if is_package_installed "gdebi"; then
                log "gdebi is already installed"
                return 0
            fi
            install_package "pacman:gdebi"
            ;;
        nixos)
            log "For NixOS, add 'gdebi' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "gdebi installation complete"
}

main "$@"
