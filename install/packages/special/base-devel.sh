#!/usr/bin/env bash
# PACKAGE: base-devel
# DESCRIPTION: Basic tools to build Arch Linux packages
# CATEGORY: special
# UBUNTU_PKG: apt:build-essential
# ARCH_PKG: pacman:base-devel
# NIX_PKG: nixpkgs.gcc nixpkgs.gnumake nixpkgs.binutils
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing base-devel..."

    # Skip if already installed
    if is_package_installed "base-devel"; then
        log "base-devel is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt:build-essential"
            ;;
        arch)
            install_package "pacman:base-devel"
            ;;
        nixos)
            log "For NixOS, add to environment.systemPackages in configuration.nix:"
            log "  gcc gnumake binutils"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "base-devel installation complete"
}

main "$@"
