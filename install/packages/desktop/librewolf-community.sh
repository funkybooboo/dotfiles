#!/usr/bin/env bash
# PACKAGE: librewolf-community
# DESCRIPTION: Package from Flathub
# CATEGORY: desktop
# UBUNTU_PKG: flatpak:io.gitlab.librewolf-community
# ARCH_PKG: pacman:librewolf-community
# NIX_PKG: nixpkgs.librewolf-community
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing librewolf-community..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "librewolf-community"; then
                log "librewolf-community is already installed"
                return 0
            fi
            install_package "flatpak:io.gitlab.librewolf-community"
            ;;
        arch)
            if is_package_installed "librewolf-community"; then
                log "librewolf-community is already installed"
                return 0
            fi
            install_package "pacman:librewolf-community"
            ;;
        nixos)
            log "For NixOS, add 'librewolf-community' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "librewolf-community installation complete"
}

main "$@"
