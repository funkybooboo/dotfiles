#!/usr/bin/env bash
# PACKAGE: ufw
# DESCRIPTION: Uncomplicated Firewall
# CATEGORY: core
# UBUNTU_PKG: apt:ufw
# ARCH_PKG: pacman:ufw
# NIX_PKG: nixpkgs.ufw
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing ufw..."

    # Skip if already installed
    if is_package_installed "ufw"; then
        log "ufw is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt:ufw"
            ;;
        arch)
            install_package "pacman:ufw"
            ;;
        nixos)
            log "For NixOS, add to configuration.nix:"
            log "  networking.firewall.enable = true;"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "ufw installation complete"
    log "Enable with: sudo ufw enable"
}

main "$@"
