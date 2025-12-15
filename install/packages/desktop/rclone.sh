#!/usr/bin/env bash
# PACKAGE: rclone
# DESCRIPTION: Package from Snap store
# CATEGORY: desktop
# UBUNTU_PKG: snap:rclone
# ARCH_PKG: pacman:rclone
# NIX_PKG: nixpkgs.rclone
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing rclone..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "rclone"; then
                log "rclone is already installed"
                return 0
            fi
            install_package "snap:rclone"
            ;;
        arch)
            if is_package_installed "rclone"; then
                log "rclone is already installed"
                return 0
            fi
            install_package "pacman:rclone"
            ;;
        nixos)
            log "For NixOS, add 'rclone' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "rclone installation complete"
}

main "$@"
