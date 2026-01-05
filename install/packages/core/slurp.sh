#!/usr/bin/env bash
# PACKAGE: slurp
# DESCRIPTION: Select a region in a Wayland compositor
# CATEGORY: core
# UBUNTU_PKG: apt:slurp
# ARCH_PKG: pacman:slurp
# NIX_PKG: nixpkgs.slurp
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing slurp..."

    # Skip if already installed
    if is_package_installed "slurp"; then
        log "slurp is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt:slurp"
            ;;
        arch)
            install_package "pacman:slurp"
            ;;
        nixos)
            log "For NixOS, add 'slurp' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "slurp installation complete"
}

main "$@"
