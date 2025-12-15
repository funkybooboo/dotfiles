#!/usr/bin/env bash
# PACKAGE: wget
# DESCRIPTION: Package from APT repository
# CATEGORY: core
# UBUNTU_PKG: apt:wget
# ARCH_PKG: pacman:wget
# NIX_PKG: nixpkgs.wget
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing wget..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "wget"; then
                log "wget is already installed"
                return 0
            fi
            install_package "apt:wget"
            ;;
        arch)
            if is_package_installed "wget"; then
                log "wget is already installed"
                return 0
            fi
            install_package "pacman:wget"
            ;;
        nixos)
            log "For NixOS, add 'wget' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "wget installation complete"
}

main "$@"
