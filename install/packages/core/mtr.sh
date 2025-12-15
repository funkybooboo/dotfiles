#!/usr/bin/env bash
# PACKAGE: mtr
# DESCRIPTION: Package from APT repository
# CATEGORY: core
# UBUNTU_PKG: apt:mtr
# ARCH_PKG: pacman:mtr
# NIX_PKG: nixpkgs.mtr
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing mtr..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "mtr"; then
                log "mtr is already installed"
                return 0
            fi
            install_package "apt:mtr"
            ;;
        arch)
            if is_package_installed "mtr"; then
                log "mtr is already installed"
                return 0
            fi
            install_package "pacman:mtr"
            ;;
        nixos)
            log "For NixOS, add 'mtr' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "mtr installation complete"
}

main "$@"
