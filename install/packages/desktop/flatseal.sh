#!/usr/bin/env bash
# PACKAGE: flatseal
# DESCRIPTION: Package from Flathub
# CATEGORY: desktop
# UBUNTU_PKG: flatpak:com.github.tchx84.Flatseal
# ARCH_PKG: pacman:flatseal
# NIX_PKG: nixpkgs.flatseal
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing flatseal..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "flatseal"; then
                log "flatseal is already installed"
                return 0
            fi
            install_package "flatpak:com.github.tchx84.Flatseal"
            ;;
        arch)
            if is_package_installed "flatseal"; then
                log "flatseal is already installed"
                return 0
            fi
            install_package "pacman:flatseal"
            ;;
        nixos)
            log "For NixOS, add 'flatseal' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "flatseal installation complete"
}

main "$@"
