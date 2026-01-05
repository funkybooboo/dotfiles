#!/usr/bin/env bash
# PACKAGE: satty
# DESCRIPTION: Screenshot annotation tool
# CATEGORY: desktop
# UBUNTU_PKG: N/A
# ARCH_PKG: aur\
# NIX_PKG: satty:nixpkgs.satty
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing satty..."

    # Skip if already installed
    if is_package_installed "satty"; then
        log "satty is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            log "ERROR: satty not available in Ubuntu repos"
return 1
            ;;
        arch)
            install_package "aur\"
            ;;
        nixos)
            log "For NixOS, add 'satty:nixpkgs.satty' to environment.systemPackages in configuration.nix"
log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "satty installation complete"
}

main "$@"
