#!/usr/bin/env bash
# PACKAGE: procs
# DESCRIPTION: Package from Snap store
# CATEGORY: desktop
# UBUNTU_PKG: snap:procs
# ARCH_PKG: pacman:procs
# NIX_PKG: nixpkgs.procs
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing procs..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "procs"; then
                log "procs is already installed"
                return 0
            fi
            install_package "snap:procs"
            ;;
        arch)
            if is_package_installed "procs"; then
                log "procs is already installed"
                return 0
            fi
            install_package "pacman:procs"
            ;;
        nixos)
            log "For NixOS, add 'procs' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "procs installation complete"
}

main "$@"
