#!/usr/bin/env bash
# PACKAGE: noto-fonts
# DESCRIPTION: Google Noto TTF fonts
# CATEGORY: fonts
# UBUNTU_PKG: apt:fonts-noto
# ARCH_PKG: pacman:noto-fonts
# NIX_PKG: nixpkgs.noto-fonts
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing noto-fonts..."

    # Skip if already installed
    if is_package_installed "noto-fonts"; then
        log "noto-fonts is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt:fonts-noto"
            ;;
        arch)
            install_package "pacman:noto-fonts"
            ;;
        nixos)
            log "For NixOS, add 'noto-fonts' to fonts.packages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "noto-fonts installation complete"
}

main "$@"
