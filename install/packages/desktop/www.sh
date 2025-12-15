#!/usr/bin/env bash
# PACKAGE: www
# DESCRIPTION: Package from Flathub
# CATEGORY: desktop
# UBUNTU_PKG: flatpak:com.protonvpn.www
# ARCH_PKG: pacman:www
# NIX_PKG: nixpkgs.www
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing www..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "www"; then
                log "www is already installed"
                return 0
            fi
            install_package "flatpak:com.protonvpn.www"
            ;;
        arch)
            if is_package_installed "www"; then
                log "www is already installed"
                return 0
            fi
            install_package "pacman:www"
            ;;
        nixos)
            log "For NixOS, add 'www' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "www installation complete"
}

main "$@"
