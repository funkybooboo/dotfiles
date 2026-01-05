#!/usr/bin/env bash
# PACKAGE: ghostty
# DESCRIPTION: Fast, feature-rich, and GPU-accelerated terminal emulator
# CATEGORY: core
# UBUNTU_PKG:
# ARCH_PKG: aur:ghostty
# NIX_PKG: nixpkgs.ghostty
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing ghostty..."

    # Skip if already installed
    if is_package_installed "ghostty"; then
        log "ghostty is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            log "ERROR: ghostty not available in Ubuntu repos, build from source"
            log "Visit: https://ghostty.org/"
            return 1
            ;;
        arch)
            install_package "aur:ghostty"
            ;;
        nixos)
            log "For NixOS, add 'ghostty' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "ghostty installation complete"
}

main "$@"
