#!/usr/bin/env bash
# PACKAGE: whois
# DESCRIPTION: Intelligent WHOIS client
# CATEGORY: core
# UBUNTU_PKG: apt:whois
# ARCH_PKG: pacman:whois
# NIX_PKG: nixpkgs.whois
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing whois..."

    # Skip if already installed
    if is_package_installed "whois"; then
        log "whois is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt:whois"
            ;;
        arch)
            install_package "pacman:whois"
            ;;
        nixos)
            log "For NixOS, add 'whois' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "whois installation complete"
}

main "$@"
