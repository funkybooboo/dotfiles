#!/usr/bin/env bash
# PACKAGE: jump
# DESCRIPTION: Package from Snap store
# CATEGORY: desktop
# UBUNTU_PKG: snap:jump
# ARCH_PKG: pacman:jump
# NIX_PKG: nixpkgs.jump
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing jump..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "jump"; then
                log "jump is already installed"
                return 0
            fi
            install_package "snap:jump"
            ;;
        arch)
            if is_package_installed "jump"; then
                log "jump is already installed"
                return 0
            fi
            install_package "pacman:jump"
            ;;
        nixos)
            log "For NixOS, add 'jump' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "jump installation complete"
}

main "$@"
