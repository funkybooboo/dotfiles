#!/usr/bin/env bash
# PACKAGE: screen
# DESCRIPTION: Full-screen window manager
# CATEGORY: core
# UBUNTU_PKG: apt\
# ARCH_PKG: screen
# NIX_PKG: pacman\:screen:nixpkgs.screen
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing screen..."

    # Skip if already installed
    if is_package_installed "screen"; then
        log "screen is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt\"
            ;;
        arch)
            install_package "screen"
            ;;
        nixos)
            log "For NixOS, add 'pacman\:screen:nixpkgs.screen' to environment.systemPackages in configuration.nix"
log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "screen installation complete"
}

main "$@"
