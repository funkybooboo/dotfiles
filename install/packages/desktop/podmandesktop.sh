#!/usr/bin/env bash
# PACKAGE: podmandesktop
# DESCRIPTION: Package from Flathub
# CATEGORY: desktop
# UBUNTU_PKG: flatpak:io.podman_desktop.PodmanDesktop
# ARCH_PKG: pacman:podmandesktop
# NIX_PKG: nixpkgs.podmandesktop
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing podmandesktop..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "podmandesktop"; then
                log "podmandesktop is already installed"
                return 0
            fi
            install_package "flatpak:io.podman_desktop.PodmanDesktop"
            ;;
        arch)
            if is_package_installed "podmandesktop"; then
                log "podmandesktop is already installed"
                return 0
            fi
            install_package "pacman:podmandesktop"
            ;;
        nixos)
            log "For NixOS, add 'podmandesktop' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "podmandesktop installation complete"
}

main "$@"
