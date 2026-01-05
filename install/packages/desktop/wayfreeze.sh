#!/usr/bin/env bash
# PACKAGE: wayfreeze
# DESCRIPTION: Screenshot-based screen freezer for Wayland
# CATEGORY: desktop
# UBUNTU_PKG:
# ARCH_PKG: pacman:wayfreeze
# NIX_PKG: nixpkgs.wayfreeze
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing wayfreeze..."

    # Skip if already installed
    if is_package_installed "wayfreeze"; then
        log "wayfreeze is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            log "ERROR: wayfreeze not available in Ubuntu repos"
            return 1
            ;;
        arch)
            install_package "pacman:wayfreeze"
            ;;
        nixos)
            log "For NixOS, add 'wayfreeze' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "wayfreeze installation complete"
}

main "$@"
