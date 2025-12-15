#!/usr/bin/env bash
# PACKAGE: multipass
# DESCRIPTION: Package from Snap store
# CATEGORY: desktop
# UBUNTU_PKG: snap:multipass
# ARCH_PKG: pacman:multipass
# NIX_PKG: nixpkgs.multipass
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing multipass..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "multipass"; then
                log "multipass is already installed"
                return 0
            fi
            install_package "snap:multipass"
            ;;
        arch)
            if is_package_installed "multipass"; then
                log "multipass is already installed"
                return 0
            fi
            install_package "pacman:multipass"
            ;;
        nixos)
            log "For NixOS, add 'multipass' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "multipass installation complete"
}

main "$@"
