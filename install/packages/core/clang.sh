#!/usr/bin/env bash
# PACKAGE: clang
# DESCRIPTION: Package from APT repository
# CATEGORY: core
# UBUNTU_PKG: apt:clang
# ARCH_PKG: pacman:clang
# NIX_PKG: nixpkgs.clang
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing clang..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "clang"; then
                log "clang is already installed"
                return 0
            fi
            install_package "apt:clang"
            ;;
        arch)
            if is_package_installed "clang"; then
                log "clang is already installed"
                return 0
            fi
            install_package "pacman:clang"
            ;;
        nixos)
            log "For NixOS, add 'clang' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "clang installation complete"
}

main "$@"
