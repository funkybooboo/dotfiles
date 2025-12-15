#!/usr/bin/env bash
# PACKAGE: gnome-calculator
# DESCRIPTION: Package from APT repository
# CATEGORY: core
# UBUNTU_PKG: apt:gnome-calculator
# ARCH_PKG: pacman:gnome-calculator
# NIX_PKG: nixpkgs.gnome-calculator
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing gnome-calculator..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "gnome-calculator"; then
                log "gnome-calculator is already installed"
                return 0
            fi
            install_package "apt:gnome-calculator"
            ;;
        arch)
            if is_package_installed "gnome-calculator"; then
                log "gnome-calculator is already installed"
                return 0
            fi
            install_package "pacman:gnome-calculator"
            ;;
        nixos)
            log "For NixOS, add 'gnome-calculator' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "gnome-calculator installation complete"
}

main "$@"
