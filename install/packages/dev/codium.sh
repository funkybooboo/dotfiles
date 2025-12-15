#!/usr/bin/env bash
# PACKAGE: codium
# DESCRIPTION: Package from Snap store (classic confinement)
# CATEGORY: dev
# UBUNTU_PKG: snap-classic:codium
# ARCH_PKG: pacman:codium
# NIX_PKG: nixpkgs.codium
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing codium..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "codium"; then
                log "codium is already installed"
                return 0
            fi
            install_package "snap-classic:codium"
            ;;
        arch)
            if is_package_installed "codium"; then
                log "codium is already installed"
                return 0
            fi
            install_package "pacman:codium"
            ;;
        nixos)
            log "For NixOS, add 'codium' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "codium installation complete"
}

main "$@"
