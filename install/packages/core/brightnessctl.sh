#!/usr/bin/env bash
# PACKAGE: brightnessctl
# DESCRIPTION: Read and control device brightness
# CATEGORY: core
# UBUNTU_PKG: apt:brightnessctl
# ARCH_PKG: pacman:brightnessctl
# NIX_PKG: nixpkgs.brightnessctl
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing brightnessctl..."

    # Skip if already installed
    if is_package_installed "brightnessctl"; then
        log "brightnessctl is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt:brightnessctl"
            ;;
        arch)
            install_package "pacman:brightnessctl"
            ;;
        nixos)
            log "For NixOS, add 'brightnessctl' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "brightnessctl installation complete"
}

main "$@"
