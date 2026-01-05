#!/usr/bin/env bash
# PACKAGE: man-db
# DESCRIPTION: Manual page database
# CATEGORY: core
# UBUNTU_PKG: apt\
# ARCH_PKG: man-db
# NIX_PKG: pacman\:man-db:nixpkgs.man-db
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing man-db..."

    # Skip if already installed
    if is_package_installed "man-db"; then
        log "man-db is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt\"
            ;;
        arch)
            install_package "man-db"
            ;;
        nixos)
            log "For NixOS, add 'pacman\:man-db:nixpkgs.man-db' to environment.systemPackages in configuration.nix"
log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "man-db installation complete"
}

main "$@"
