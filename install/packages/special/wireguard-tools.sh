#!/usr/bin/env bash
# PACKAGE: wireguard-tools
# DESCRIPTION: WireGuard VPN tools
# CATEGORY: special
# UBUNTU_PKG: apt\
# ARCH_PKG: wireguard-tools
# NIX_PKG: pacman\:wireguard-tools:nixpkgs.wireguard-tools
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing wireguard-tools..."

    # Skip if already installed
    if is_package_installed "wireguard-tools"; then
        log "wireguard-tools is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt\"
            ;;
        arch)
            install_package "wireguard-tools"
            ;;
        nixos)
            log "For NixOS, add 'pacman\:wireguard-tools:nixpkgs.wireguard-tools' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "wireguard-tools installation complete"
}

main "$@"
