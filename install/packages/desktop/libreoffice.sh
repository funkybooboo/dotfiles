#!/usr/bin/env bash
# PACKAGE: libreoffice
# DESCRIPTION: Package from Snap store
# CATEGORY: desktop
# UBUNTU_PKG: snap:libreoffice
# ARCH_PKG: pacman:libreoffice
# NIX_PKG: nixpkgs.libreoffice
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing libreoffice..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "libreoffice"; then
                log "libreoffice is already installed"
                return 0
            fi
            install_package "snap:libreoffice"
            ;;
        arch)
            if is_package_installed "libreoffice"; then
                log "libreoffice is already installed"
                return 0
            fi
            install_package "pacman:libreoffice"
            ;;
        nixos)
            log "For NixOS, add 'libreoffice' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "libreoffice installation complete"
}

main "$@"
