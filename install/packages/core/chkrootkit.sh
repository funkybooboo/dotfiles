#!/usr/bin/env bash
# PACKAGE: chkrootkit
# DESCRIPTION: Package from APT repository
# CATEGORY: core
# UBUNTU_PKG: apt:chkrootkit
# ARCH_PKG: pacman:chkrootkit
# NIX_PKG: nixpkgs.chkrootkit
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing chkrootkit..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "chkrootkit"; then
                log "chkrootkit is already installed"
                return 0
            fi
            install_package "apt:chkrootkit"
            ;;
        arch)
            if is_package_installed "chkrootkit"; then
                log "chkrootkit is already installed"
                return 0
            fi
            install_package "pacman:chkrootkit"
            ;;
        nixos)
            log "For NixOS, add 'chkrootkit' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "chkrootkit installation complete"
}

main "$@"
