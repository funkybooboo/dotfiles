#!/usr/bin/env bash
# PACKAGE: noto-fonts-emoji
# DESCRIPTION: Google Noto emoji fonts
# CATEGORY: fonts
# UBUNTU_PKG: apt:fonts-noto-color-emoji
# ARCH_PKG: pacman:noto-fonts-emoji
# NIX_PKG: nixpkgs.noto-fonts-emoji
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing noto-fonts-emoji..."

    # Skip if already installed
    if is_package_installed "noto-fonts-emoji"; then
        log "noto-fonts-emoji is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt:fonts-noto-color-emoji"
            ;;
        arch)
            install_package "pacman:noto-fonts-emoji"
            ;;
        nixos)
            log "For NixOS, add 'noto-fonts-emoji' to fonts.packages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "noto-fonts-emoji installation complete"
}

main "$@"
