#!/usr/bin/env bash
# PACKAGE: xprintidle
# DESCRIPTION: Package from APT repository
# CATEGORY: core
# UBUNTU_PKG: apt:xprintidle
# ARCH_PKG: pacman:xprintidle
# NIX_PKG: nixpkgs.xprintidle
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing xprintidle..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "xprintidle"; then
                log "xprintidle is already installed"
                return 0
            fi
            install_package "apt:xprintidle"
            ;;
        arch)
            if is_package_installed "xprintidle"; then
                log "xprintidle is already installed"
                return 0
            fi
            install_package "pacman:xprintidle"
            ;;
        nixos)
            log "For NixOS, add 'xprintidle' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "xprintidle installation complete"
}

main "$@"
