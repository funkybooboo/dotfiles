#!/usr/bin/env bash
# PACKAGE: plocate
# DESCRIPTION: Package from APT repository
# CATEGORY: core
# UBUNTU_PKG: apt:plocate
# ARCH_PKG: pacman:plocate
# NIX_PKG: nixpkgs.plocate
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing plocate..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "plocate"; then
                log "plocate is already installed"
                return 0
            fi
            install_package "apt:plocate"
            ;;
        arch)
            if is_package_installed "plocate"; then
                log "plocate is already installed"
                return 0
            fi
            install_package "pacman:plocate"
            ;;
        nixos)
            log "For NixOS, add 'plocate' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "plocate installation complete"
}

main "$@"
