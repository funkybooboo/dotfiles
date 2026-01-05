#!/usr/bin/env bash
# PACKAGE: llvm
# DESCRIPTION: LLVM compiler infrastructure
# CATEGORY: dev
# UBUNTU_PKG: apt\
# ARCH_PKG: llvm
# NIX_PKG: pacman\:llvm:nixpkgs.llvm
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing llvm..."

    # Skip if already installed
    if is_package_installed "llvm"; then
        log "llvm is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt\"
            ;;
        arch)
            install_package "llvm"
            ;;
        nixos)
            log "For NixOS, add 'pacman\:llvm:nixpkgs.llvm' to environment.systemPackages in configuration.nix"
log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "llvm installation complete"
}

main "$@"
