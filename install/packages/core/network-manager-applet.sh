#!/usr/bin/env bash
# PACKAGE: network-manager-applet
# DESCRIPTION: NetworkManager tray applet
# CATEGORY: core
# UBUNTU_PKG: apt\
# ARCH_PKG: network-manager-gnome
# NIX_PKG: pacman\:network-manager-applet:nixpkgs.networkmanagerapplet
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing network-manager-applet..."

    # Skip if already installed
    if is_package_installed "network-manager-applet"; then
        log "network-manager-applet is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt\"
            ;;
        arch)
            install_package "network-manager-gnome"
            ;;
        nixos)
            log "For NixOS, add 'pacman\:network-manager-applet:nixpkgs.networkmanagerapplet' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "network-manager-applet installation complete"
}

main "$@"
