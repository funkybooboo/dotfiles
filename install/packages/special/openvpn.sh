#!/usr/bin/env bash
# PACKAGE: openvpn
# DESCRIPTION: OpenVPN client and server
# CATEGORY: special
# UBUNTU_PKG: apt\
# ARCH_PKG: openvpn
# NIX_PKG: pacman\:openvpn:nixpkgs.openvpn
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing openvpn..."

    # Skip if already installed
    if is_package_installed "openvpn"; then
        log "openvpn is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt\"
            ;;
        arch)
            install_package "openvpn"
            ;;
        nixos)
            log "For NixOS, add 'pacman\:openvpn:nixpkgs.openvpn' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "openvpn installation complete"
}

main "$@"
