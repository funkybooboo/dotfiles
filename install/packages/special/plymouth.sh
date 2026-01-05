#!/usr/bin/env bash
# PACKAGE: plymouth
# DESCRIPTION: Boot splash screen
# CATEGORY: special
# UBUNTU_PKG: apt\
# ARCH_PKG: plymouth
# NIX_PKG: pacman\:plymouth:nixpkgs.plymouth
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing plymouth..."

    # Skip if already installed
    if is_package_installed "plymouth"; then
        log "plymouth is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt\"
            ;;
        arch)
            install_package "plymouth"
            ;;
        nixos)
            log "For NixOS, add 'pacman\:plymouth:nixpkgs.plymouth' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "plymouth installation complete"
}

main "$@"
