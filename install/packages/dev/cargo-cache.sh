#!/usr/bin/env bash
# PACKAGE: cargo-cache
# DESCRIPTION: Rust package from crates.io
# CATEGORY: dev
# UBUNTU_PKG: cargo:cargo-cache
# ARCH_PKG: pacman:cargo-cache
# NIX_PKG: nixpkgs.cargo-cache
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing cargo-cache..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "cargo-cache"; then
                log "cargo-cache is already installed"
                return 0
            fi
            install_package "cargo:cargo-cache"
            ;;
        arch)
            if is_package_installed "cargo-cache"; then
                log "cargo-cache is already installed"
                return 0
            fi
            install_package "pacman:cargo-cache"
            ;;
        nixos)
            log "For NixOS, add 'cargo-cache' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "cargo-cache installation complete"
}

main "$@"
