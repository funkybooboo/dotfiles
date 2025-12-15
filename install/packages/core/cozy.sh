#!/usr/bin/env bash
# PACKAGE: cozy
# DESCRIPTION: Package from APT repository
# CATEGORY: core
# UBUNTU_PKG: apt:cozy
# ARCH_PKG: pacman:cozy
# NIX_PKG: nixpkgs.cozy
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing cozy..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "cozy"; then
                log "cozy is already installed"
                return 0
            fi
            install_package "apt:cozy"
            ;;
        arch)
            if is_package_installed "cozy"; then
                log "cozy is already installed"
                return 0
            fi
            install_package "pacman:cozy"
            ;;
        nixos)
            log "For NixOS, add 'cozy' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "cozy installation complete"
}

main "$@"
