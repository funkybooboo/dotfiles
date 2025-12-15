#!/usr/bin/env bash
# PACKAGE: virt-manager
# DESCRIPTION: Package from APT repository
# CATEGORY: core
# UBUNTU_PKG: apt:virt-manager
# ARCH_PKG: pacman:virt-manager
# NIX_PKG: nixpkgs.virt-manager
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing virt-manager..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "virt-manager"; then
                log "virt-manager is already installed"
                return 0
            fi
            install_package "apt:virt-manager"
            ;;
        arch)
            if is_package_installed "virt-manager"; then
                log "virt-manager is already installed"
                return 0
            fi
            install_package "pacman:virt-manager"
            ;;
        nixos)
            log "For NixOS, add 'virt-manager' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "virt-manager installation complete"
}

main "$@"
