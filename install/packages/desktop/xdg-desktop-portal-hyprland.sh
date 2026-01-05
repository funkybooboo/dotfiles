#!/usr/bin/env bash
# PACKAGE: xdg-desktop-portal-hyprland
# DESCRIPTION: XDG Desktop Portal backend for Hyprland
# CATEGORY: desktop
# UBUNTU_PKG:
# ARCH_PKG: pacman:xdg-desktop-portal-hyprland
# NIX_PKG: nixpkgs.xdg-desktop-portal-hyprland
# DEPENDS: xdg-desktop-portal
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing xdg-desktop-portal-hyprland..."

    # Skip if already installed
    if is_package_installed "xdg-desktop-portal-hyprland"; then
        log "xdg-desktop-portal-hyprland is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            log "ERROR: xdg-desktop-portal-hyprland not available in Ubuntu repos"
            return 1
            ;;
        arch)
            install_package "pacman:xdg-desktop-portal-hyprland"
            ;;
        nixos)
            log "For NixOS, add 'xdg-desktop-portal-hyprland' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "xdg-desktop-portal-hyprland installation complete"
}

main "$@"
