#!/usr/bin/env bash
# PACKAGE: flatpak
# DESCRIPTION: Application sandboxing and distribution framework
# CATEGORY: core
# UBUNTU_PKG: apt:flatpak
# ARCH_PKG: pacman:flatpak
# NIX_PKG: nixpkgs.flatpak
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing flatpak..."

    # Skip if already installed
    if is_package_installed "flatpak"; then
        log "flatpak is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt:flatpak"
            log "Adding Flathub repository..."
            flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
            ;;
        arch)
            install_package "pacman:flatpak"
            log "Adding Flathub repository..."
            flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
            ;;
        nixos)
            log "For NixOS, add to configuration.nix:"
            log "  services.flatpak.enable = true;"
            log "Then run: sudo nixos-rebuild switch"
            log "Then add Flathub: flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "flatpak installation complete"
}

main "$@"
