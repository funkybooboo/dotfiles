#!/usr/bin/env bash
# PACKAGE: hyprland
# DESCRIPTION: Dynamic tiling Wayland compositor
# CATEGORY: desktop
# UBUNTU_PKG:
# ARCH_PKG: pacman:hyprland
# NIX_PKG: nixpkgs.hyprland
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing hyprland..."

    # Skip if already installed
    if is_package_installed "hyprland"; then
        log "hyprland is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            log "ERROR: Hyprland not available in Ubuntu repos, build from source or use PPA"
            return 1
            ;;
        arch)
            install_package "pacman:hyprland"
            ;;
        nixos)
            log "For NixOS, add 'hyprland' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "hyprland installation complete"
}

main "$@"
