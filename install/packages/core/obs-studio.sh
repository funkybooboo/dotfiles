#!/usr/bin/env bash
# PACKAGE: obs-studio
# DESCRIPTION: Free and open source software for video recording and live streaming
# CATEGORY: core
# UBUNTU_PKG: apt:obs-studio
# ARCH_PKG: pacman:obs-studio
# NIX_PKG: nixpkgs.obs-studio
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing obs-studio..."

    # Skip if already installed
    if is_package_installed "obs-studio"; then
        log "obs-studio is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt:obs-studio"
            ;;
        arch)
            install_package "pacman:obs-studio"
            ;;
        nixos)
            log "For NixOS, add 'obs-studio' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "obs-studio installation complete"
}

main "$@"
