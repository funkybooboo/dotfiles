#!/usr/bin/env bash
# PACKAGE: cmake
# DESCRIPTION: Package from APT repository
# CATEGORY: core
# UBUNTU_PKG: apt:cmake
# ARCH_PKG: pacman:cmake
# NIX_PKG: nixpkgs.cmake
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing cmake..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "cmake"; then
                log "cmake is already installed"
                return 0
            fi
            install_package "apt:cmake"
            ;;
        arch)
            if is_package_installed "cmake"; then
                log "cmake is already installed"
                return 0
            fi
            install_package "pacman:cmake"
            ;;
        nixos)
            log "For NixOS, add 'cmake' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "cmake installation complete"
}

main "$@"
