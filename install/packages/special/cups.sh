#!/usr/bin/env bash
# PACKAGE: cups
# DESCRIPTION: Common UNIX Printing System
# CATEGORY: special
# UBUNTU_PKG: apt:cups
# ARCH_PKG: pacman:cups
# NIX_PKG: nixpkgs.cups
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing cups..."

    # Skip if already installed
    if is_package_installed "cups"; then
        log "cups is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt:cups"
            sudo systemctl enable cups
            sudo systemctl start cups
            ;;
        arch)
            install_package "pacman:cups"
            sudo systemctl enable cups.service
            sudo systemctl start cups.service
            ;;
        nixos)
            log "For NixOS, add to configuration.nix:"
            log "  services.printing.enable = true;"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "cups installation complete"
}

main "$@"
