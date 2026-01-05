#!/usr/bin/env bash
# PACKAGE: unzip
# DESCRIPTION: Extraction utility for .zip archives
# CATEGORY: core
# UBUNTU_PKG: apt:unzip
# ARCH_PKG: pacman:unzip
# NIX_PKG: nixpkgs.unzip
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing unzip..."

    # Skip if already installed
    if is_package_installed "unzip"; then
        log "unzip is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt:unzip"
            ;;
        arch)
            install_package "pacman:unzip"
            ;;
        nixos)
            log "For NixOS, add 'unzip' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "unzip installation complete"
}

main "$@"
