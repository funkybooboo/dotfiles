#!/usr/bin/env bash
# PACKAGE: zoom
# DESCRIPTION: Video conferencing and web conferencing service
# CATEGORY: desktop
# UBUNTU_PKG:
# ARCH_PKG: aur:zoom
# NIX_PKG: nixpkgs.zoom-us
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing zoom..."

    # Skip if already installed
    if is_package_installed "zoom"; then
        log "zoom is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            log "Downloading Zoom .deb package..."
            cd /tmp
            wget https://zoom.us/client/latest/zoom_amd64.deb
            sudo apt install ./zoom_amd64.deb
            rm zoom_amd64.deb
            ;;
        arch)
            install_package "aur:zoom"
            ;;
        nixos)
            log "For NixOS, add 'zoom-us' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "zoom installation complete"
}

main "$@"
