#!/usr/bin/env bash
# PACKAGE: clamav-daemon
# DESCRIPTION: Package from APT repository
# CATEGORY: core
# UBUNTU_PKG: apt:clamav-daemon
# ARCH_PKG: pacman:clamav-daemon
# NIX_PKG: nixpkgs.clamav-daemon
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing clamav-daemon..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "clamav-daemon"; then
                log "clamav-daemon is already installed"
                return 0
            fi
            install_package "apt:clamav-daemon"
            ;;
        arch)
            if is_package_installed "clamav-daemon"; then
                log "clamav-daemon is already installed"
                return 0
            fi
            install_package "pacman:clamav-daemon"
            ;;
        nixos)
            log "For NixOS, add 'clamav-daemon' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "clamav-daemon installation complete"
}

main "$@"
