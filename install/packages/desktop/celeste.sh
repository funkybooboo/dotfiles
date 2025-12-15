#!/usr/bin/env bash
# PACKAGE: celeste
# DESCRIPTION: Package from Flathub
# CATEGORY: desktop
# UBUNTU_PKG: flatpak:com.hunterwittenborn.Celeste
# ARCH_PKG: pacman:celeste
# NIX_PKG: nixpkgs.celeste
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing celeste..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "celeste"; then
                log "celeste is already installed"
                return 0
            fi
            install_package "flatpak:com.hunterwittenborn.Celeste"
            ;;
        arch)
            if is_package_installed "celeste"; then
                log "celeste is already installed"
                return 0
            fi
            install_package "pacman:celeste"
            ;;
        nixos)
            log "For NixOS, add 'celeste' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "celeste installation complete"
}

main "$@"
