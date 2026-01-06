#!/usr/bin/env bash
# PACKAGE: xmlstarlet
# DESCRIPTION: A set of tools to transform, query, validate, and edit XML documents
# CATEGORY: core
# UBUNTU_PKG: apt:xmlstarlet
# ARCH_PKG: pacman:xmlstarlet
# NIX_PKG: nixpkgs.xmlstarlet
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing xmlstarlet..."

    # Skip if already installed
    if is_package_installed "xmlstarlet"; then
        log "xmlstarlet is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt:xmlstarlet"
            ;;
        arch)
            install_package "pacman:xmlstarlet"
            ;;
        nixos)
            log "For NixOS, add 'xmlstarlet' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "xmlstarlet installation complete"
}

main "$@"
