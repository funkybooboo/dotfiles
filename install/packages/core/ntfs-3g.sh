#!/usr/bin/env bash
# PACKAGE: ntfs-3g
# DESCRIPTION: Package from APT repository
# CATEGORY: core
# UBUNTU_PKG: apt:ntfs-3g
# ARCH_PKG: pacman:ntfs-3g
# NIX_PKG: nixpkgs.ntfs-3g
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing ntfs-3g..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "ntfs-3g"; then
                log "ntfs-3g is already installed"
                return 0
            fi
            install_package "apt:ntfs-3g"
            ;;
        arch)
            if is_package_installed "ntfs-3g"; then
                log "ntfs-3g is already installed"
                return 0
            fi
            install_package "pacman:ntfs-3g"
            ;;
        nixos)
            log "For NixOS, add 'ntfs-3g' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "ntfs-3g installation complete"
}

main "$@"
