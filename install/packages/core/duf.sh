#!/usr/bin/env bash
# PACKAGE: duf
# DESCRIPTION: Package from APT repository
# CATEGORY: core
# UBUNTU_PKG: apt:duf
# ARCH_PKG: pacman:duf
# NIX_PKG: nixpkgs.duf
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing duf..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "duf"; then
                log "duf is already installed"
                return 0
            fi
            install_package "apt:duf"
            ;;
        arch)
            if is_package_installed "duf"; then
                log "duf is already installed"
                return 0
            fi
            install_package "pacman:duf"
            ;;
        nixos)
            log "For NixOS, add 'duf' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "duf installation complete"
}

main "$@"
