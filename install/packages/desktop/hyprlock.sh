#!/usr/bin/env bash
# PACKAGE: hyprlock
# DESCRIPTION: Hyprland's GPU-accelerated screen lock
# CATEGORY: desktop
# UBUNTU_PKG:
# ARCH_PKG: pacman:hyprlock
# NIX_PKG: nixpkgs.hyprlock
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing hyprlock..."

    # Skip if already installed
    if is_package_installed "hyprlock"; then
        log "hyprlock is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            log "ERROR: hyprlock not available in Ubuntu repos, build from source"
            return 1
            ;;
        arch)
            install_package "pacman:hyprlock"
            ;;
        nixos)
            log "For NixOS, add 'hyprlock' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "hyprlock installation complete"
}

main "$@"
