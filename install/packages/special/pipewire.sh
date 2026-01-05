#!/usr/bin/env bash
# PACKAGE: pipewire
# DESCRIPTION: Multimedia processing
# CATEGORY: special
# UBUNTU_PKG: apt\
# ARCH_PKG: pipewire
# NIX_PKG: pacman\:pipewire:nixpkgs.pipewire
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing pipewire..."

    # Skip if already installed
    if is_package_installed "pipewire"; then
        log "pipewire is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt\"
            ;;
        arch)
            install_package "pipewire"
            ;;
        nixos)
            log "For NixOS, add 'pacman\:pipewire:nixpkgs.pipewire' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "pipewire installation complete"
}

main "$@"
