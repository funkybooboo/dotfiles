#!/usr/bin/env bash
# PACKAGE: steam
# DESCRIPTION: Valve's digital distribution platform for games
# CATEGORY: core
# UBUNTU_PKG: apt:steam
# ARCH_PKG: pacman:steam
# NIX_PKG: nixpkgs.steam
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing steam..."

    # Skip if already installed
    if is_package_installed "steam"; then
        log "steam is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            log "Enabling 32-bit architecture..."
            sudo dpkg --add-architecture i386
            sudo apt update
            install_package "apt:steam"
            ;;
        arch)
            log "Enabling multilib repository..."
            log "Ensure [multilib] is enabled in /etc/pacman.conf"
            install_package "pacman:steam"
            ;;
        nixos)
            log "For NixOS, add to configuration.nix:"
            log "  programs.steam.enable = true;"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "steam installation complete"
}

main "$@"
