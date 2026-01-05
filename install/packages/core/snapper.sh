#!/usr/bin/env bash
# PACKAGE: snapper
# DESCRIPTION: Manage filesystem snapshots
# CATEGORY: core
# UBUNTU_PKG: apt\
# ARCH_PKG: snapper
# NIX_PKG: pacman\:snapper:nixpkgs.snapper
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing snapper..."

    # Skip if already installed
    if is_package_installed "snapper"; then
        log "snapper is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt\"
            ;;
        arch)
            install_package "snapper"
            ;;
        nixos)
            log "For NixOS, add 'pacman\:snapper:nixpkgs.snapper' to environment.systemPackages in configuration.nix"
log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "snapper installation complete"
}

main "$@"
