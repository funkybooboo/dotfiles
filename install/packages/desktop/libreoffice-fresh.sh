#!/usr/bin/env bash
# PACKAGE: libreoffice-fresh
# DESCRIPTION: LibreOffice - Fresh branch
# CATEGORY: desktop
# UBUNTU_PKG: apt:libreoffice
# ARCH_PKG: pacman:libreoffice-fresh
# NIX_PKG: nixpkgs.libreoffice-fresh
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing libreoffice-fresh..."

    # Skip if already installed
    if is_package_installed "libreoffice-fresh" || is_package_installed "libreoffice"; then
        log "libreoffice-fresh is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt:libreoffice"
            ;;
        arch)
            install_package "pacman:libreoffice-fresh"
            ;;
        nixos)
            log "For NixOS, add 'libreoffice-fresh' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "libreoffice-fresh installation complete"
}

main "$@"
