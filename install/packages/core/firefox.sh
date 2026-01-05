#!/usr/bin/env bash
# PACKAGE: firefox
# DESCRIPTION: Mozilla Firefox web browser
# CATEGORY: core
# UBUNTU_PKG: apt:firefox
# ARCH_PKG: pacman:firefox
# NIX_PKG: nixpkgs.firefox
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing firefox..."

    # Skip if already installed
    if is_package_installed "firefox"; then
        log "firefox is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt:firefox"
            ;;
        arch)
            install_package "pacman:firefox"
            ;;
        nixos)
            log "For NixOS, add 'firefox' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "firefox installation complete"
}

main "$@"
