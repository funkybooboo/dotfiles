#!/usr/bin/env bash
# PACKAGE: wofi
# DESCRIPTION: Launcher for wlroots compositors
# CATEGORY: desktop
# UBUNTU_PKG: apt\
# ARCH_PKG: wofi
# NIX_PKG: pacman\:wofi:nixpkgs.wofi
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing wofi..."

    # Skip if already installed
    if is_package_installed "wofi"; then
        log "wofi is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt\"
            ;;
        arch)
            install_package "wofi"
            ;;
        nixos)
            log "For NixOS, add 'pacman\:wofi:nixpkgs.wofi' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "wofi installation complete"
}

main "$@"
