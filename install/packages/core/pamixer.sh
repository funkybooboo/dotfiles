#!/usr/bin/env bash
# PACKAGE: pamixer
# DESCRIPTION: Pulseaudio command-line mixer
# CATEGORY: core
# UBUNTU_PKG: apt\
# ARCH_PKG: pamixer
# NIX_PKG: pacman\:pamixer:nixpkgs.pamixer
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing pamixer..."

    # Skip if already installed
    if is_package_installed "pamixer"; then
        log "pamixer is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt\"
            ;;
        arch)
            install_package "pamixer"
            ;;
        nixos)
            log "For NixOS, add 'pacman\:pamixer:nixpkgs.pamixer' to environment.systemPackages in configuration.nix"
log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "pamixer installation complete"
}

main "$@"
