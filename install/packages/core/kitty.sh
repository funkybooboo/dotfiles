#!/usr/bin/env bash
# PACKAGE: kitty
# DESCRIPTION: Package from APT repository
# CATEGORY: core
# UBUNTU_PKG: apt:kitty
# ARCH_PKG: pacman:kitty
# NIX_PKG: nixpkgs.kitty
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing kitty..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "kitty"; then
                log "kitty is already installed"
                return 0
            fi
            install_package "apt:kitty"
            ;;
        arch)
            if is_package_installed "kitty"; then
                log "kitty is already installed"
                return 0
            fi
            install_package "pacman:kitty"
            ;;
        nixos)
            log "For NixOS, add 'kitty' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "kitty installation complete"
}

main "$@"
