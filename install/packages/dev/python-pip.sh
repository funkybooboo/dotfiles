#!/usr/bin/env bash
# PACKAGE: python-pip
# DESCRIPTION: Python package installer
# CATEGORY: dev
# UBUNTU_PKG: apt:python3-pip
# ARCH_PKG: pacman:python-pip
# NIX_PKG: nixpkgs.python3Packages.pip
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing python-pip..."

    # Skip if already installed
    if is_package_installed "python-pip" || is_package_installed "python3-pip"; then
        log "python-pip is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt:python3-pip"
            ;;
        arch)
            install_package "pacman:python-pip"
            ;;
        nixos)
            log "For NixOS, add 'python3Packages.pip' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "python-pip installation complete"
}

main "$@"
