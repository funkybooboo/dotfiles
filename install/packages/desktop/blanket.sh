#!/usr/bin/env bash
# PACKAGE: blanket
# DESCRIPTION: Package from Snap store
# CATEGORY: desktop
# UBUNTU_PKG: snap:blanket
# ARCH_PKG: pacman:blanket
# NIX_PKG: nixpkgs.blanket
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing blanket..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "blanket"; then
                log "blanket is already installed"
                return 0
            fi
            install_package "snap:blanket"
            ;;
        arch)
            if is_package_installed "blanket"; then
                log "blanket is already installed"
                return 0
            fi
            install_package "pacman:blanket"
            ;;
        nixos)
            log "For NixOS, add 'blanket' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "blanket installation complete"
}

main "$@"
