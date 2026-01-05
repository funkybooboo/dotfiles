#!/usr/bin/env bash
# PACKAGE: clang
# DESCRIPTION: C language family frontend for LLVM
# CATEGORY: dev
# UBUNTU_PKG: apt\
# ARCH_PKG: clang
# NIX_PKG: pacman\:clang:nixpkgs.clang
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

    # Skip if already installed
    if is_package_installed "clang"; then
        log "clang is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt\"
            ;;
        arch)
            install_package "clang"
            ;;
        nixos)
            log "For NixOS, add 'pacman\:clang:nixpkgs.clang' to environment.systemPackages in configuration.nix"
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
