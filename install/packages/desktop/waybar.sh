#!/usr/bin/env bash
# PACKAGE: waybar
# DESCRIPTION: Highly customizable Wayland bar for Sway and Hyprland
# CATEGORY: desktop
# UBUNTU_PKG: apt:waybar
# ARCH_PKG: pacman:waybar
# NIX_PKG: nixpkgs.waybar
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing waybar..."

    # Skip if already installed
    if is_package_installed "waybar"; then
        log "waybar is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt:waybar"
            ;;
        arch)
            install_package "pacman:waybar"
            ;;
        nixos)
            log "For NixOS, add 'waybar' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "waybar installation complete"
}

main "$@"
