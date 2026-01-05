#!/usr/bin/env bash
# PACKAGE: gzip
# DESCRIPTION: GNU compression utilities
# CATEGORY: core
# UBUNTU_PKG: apt\
# ARCH_PKG: gzip
# NIX_PKG: pacman\:gzip:nixpkgs.gzip
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing gzip..."

    # Skip if already installed
    if is_package_installed "gzip"; then
        log "gzip is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt\"
            ;;
        arch)
            install_package "gzip"
            ;;
        nixos)
            log "For NixOS, add 'pacman\:gzip:nixpkgs.gzip' to environment.systemPackages in configuration.nix"
log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "gzip installation complete"
}

main "$@"
