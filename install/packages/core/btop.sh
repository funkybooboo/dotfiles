#!/usr/bin/env bash
# PACKAGE: btop
# DESCRIPTION: Resource monitor with mouse support and a customizable interface
# CATEGORY: core
# UBUNTU_PKG: apt:btop
# ARCH_PKG: pacman:btop
# NIX_PKG: nixpkgs.btop
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing btop..."

    # Skip if already installed
    if is_package_installed "btop"; then
        log "btop is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt:btop"
            ;;
        arch)
            install_package "pacman:btop"
            ;;
        nixos)
            log "For NixOS, add 'btop' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "btop installation complete"
}

main "$@"
