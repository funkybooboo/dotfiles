#!/usr/bin/env bash
# PACKAGE: power-profiles-daemon
# DESCRIPTION: Package from APT repository
# CATEGORY: core
# UBUNTU_PKG: apt:power-profiles-daemon
# ARCH_PKG: pacman:power-profiles-daemon
# NIX_PKG: nixpkgs.power-profiles-daemon
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing power-profiles-daemon..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "power-profiles-daemon"; then
                log "power-profiles-daemon is already installed"
                return 0
            fi
            install_package "apt:power-profiles-daemon"
            ;;
        arch)
            if is_package_installed "power-profiles-daemon"; then
                log "power-profiles-daemon is already installed"
                return 0
            fi
            install_package "pacman:power-profiles-daemon"
            ;;
        nixos)
            log "For NixOS, add 'power-profiles-daemon' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "power-profiles-daemon installation complete"
}

main "$@"
