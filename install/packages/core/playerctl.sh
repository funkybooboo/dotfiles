#!/usr/bin/env bash
# PACKAGE: playerctl
# DESCRIPTION: Command-line utility for controlling media players
# CATEGORY: core
# UBUNTU_PKG: apt:playerctl
# ARCH_PKG: pacman:playerctl
# NIX_PKG: nixpkgs.playerctl
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing playerctl..."

    # Skip if already installed
    if is_package_installed "playerctl"; then
        log "playerctl is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt:playerctl"
            ;;
        arch)
            install_package "pacman:playerctl"
            ;;
        nixos)
            log "For NixOS, add 'playerctl' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "playerctl installation complete"
}

main "$@"
