#!/usr/bin/env bash
# PACKAGE: nmap
# DESCRIPTION: Utility for network discovery and security auditing
# CATEGORY: core
# UBUNTU_PKG: apt:nmap
# ARCH_PKG: pacman:nmap
# NIX_PKG: nixpkgs.nmap
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing nmap..."

    # Skip if already installed
    if is_package_installed "nmap"; then
        log "nmap is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt:nmap"
            ;;
        arch)
            install_package "pacman:nmap"
            ;;
        nixos)
            log "For NixOS, add 'nmap' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "nmap installation complete"
}

main "$@"
