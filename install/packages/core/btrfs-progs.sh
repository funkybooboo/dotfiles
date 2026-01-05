#!/usr/bin/env bash
# PACKAGE: btrfs-progs
# DESCRIPTION: Btrfs filesystem utilities
# CATEGORY: core
# UBUNTU_PKG: apt\
# ARCH_PKG: btrfs-progs
# NIX_PKG: pacman\:btrfs-progs:nixpkgs.btrfs-progs
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing btrfs-progs..."

    # Skip if already installed
    if is_package_installed "btrfs-progs"; then
        log "btrfs-progs is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt\"
            ;;
        arch)
            install_package "btrfs-progs"
            ;;
        nixos)
            log "For NixOS, add 'pacman\:btrfs-progs:nixpkgs.btrfs-progs' to environment.systemPackages in configuration.nix"
log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "btrfs-progs installation complete"
}

main "$@"
