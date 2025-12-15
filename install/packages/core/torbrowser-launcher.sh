#!/usr/bin/env bash
# PACKAGE: torbrowser-launcher
# DESCRIPTION: Package from APT repository
# CATEGORY: core
# UBUNTU_PKG: apt:torbrowser-launcher
# ARCH_PKG: pacman:torbrowser-launcher
# NIX_PKG: nixpkgs.torbrowser-launcher
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing torbrowser-launcher..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "torbrowser-launcher"; then
                log "torbrowser-launcher is already installed"
                return 0
            fi
            install_package "apt:torbrowser-launcher"
            ;;
        arch)
            if is_package_installed "torbrowser-launcher"; then
                log "torbrowser-launcher is already installed"
                return 0
            fi
            install_package "pacman:torbrowser-launcher"
            ;;
        nixos)
            log "For NixOS, add 'torbrowser-launcher' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "torbrowser-launcher installation complete"
}

main "$@"
