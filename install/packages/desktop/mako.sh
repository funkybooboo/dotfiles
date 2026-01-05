#!/usr/bin/env bash
# PACKAGE: mako
# DESCRIPTION: Lightweight notification daemon
# CATEGORY: desktop
# UBUNTU_PKG: apt\
# ARCH_PKG: mako-notifier
# NIX_PKG: pacman\:mako:nixpkgs.mako
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing mako..."

    # Skip if already installed
    if is_package_installed "mako"; then
        log "mako is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt\"
            ;;
        arch)
            install_package "mako-notifier"
            ;;
        nixos)
            log "For NixOS, add 'pacman\:mako:nixpkgs.mako' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "mako installation complete"
}

main "$@"
