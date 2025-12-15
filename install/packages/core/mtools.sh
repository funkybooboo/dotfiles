#!/usr/bin/env bash
# PACKAGE: mtools
# DESCRIPTION: Package from APT repository
# CATEGORY: core
# UBUNTU_PKG: apt:mtools
# ARCH_PKG: pacman:mtools
# NIX_PKG: nixpkgs.mtools
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing mtools..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "mtools"; then
                log "mtools is already installed"
                return 0
            fi
            install_package "apt:mtools"
            ;;
        arch)
            if is_package_installed "mtools"; then
                log "mtools is already installed"
                return 0
            fi
            install_package "pacman:mtools"
            ;;
        nixos)
            log "For NixOS, add 'mtools' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "mtools installation complete"
}

main "$@"
