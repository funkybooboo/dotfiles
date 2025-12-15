#!/usr/bin/env bash
# PACKAGE: gnome-disk-utility
# DESCRIPTION: Package from APT repository
# CATEGORY: core
# UBUNTU_PKG: apt:gnome-disk-utility
# ARCH_PKG: pacman:gnome-disk-utility
# NIX_PKG: nixpkgs.gnome-disk-utility
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing gnome-disk-utility..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "gnome-disk-utility"; then
                log "gnome-disk-utility is already installed"
                return 0
            fi
            install_package "apt:gnome-disk-utility"
            ;;
        arch)
            if is_package_installed "gnome-disk-utility"; then
                log "gnome-disk-utility is already installed"
                return 0
            fi
            install_package "pacman:gnome-disk-utility"
            ;;
        nixos)
            log "For NixOS, add 'gnome-disk-utility' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "gnome-disk-utility installation complete"
}

main "$@"
