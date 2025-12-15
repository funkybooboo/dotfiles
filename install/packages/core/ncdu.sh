#!/usr/bin/env bash
# PACKAGE: ncdu
# DESCRIPTION: Package from APT repository
# CATEGORY: core
# UBUNTU_PKG: apt:ncdu
# ARCH_PKG: pacman:ncdu
# NIX_PKG: nixpkgs.ncdu
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing ncdu..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "ncdu"; then
                log "ncdu is already installed"
                return 0
            fi
            install_package "apt:ncdu"
            ;;
        arch)
            if is_package_installed "ncdu"; then
                log "ncdu is already installed"
                return 0
            fi
            install_package "pacman:ncdu"
            ;;
        nixos)
            log "For NixOS, add 'ncdu' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "ncdu installation complete"
}

main "$@"
