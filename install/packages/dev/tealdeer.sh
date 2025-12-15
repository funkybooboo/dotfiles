#!/usr/bin/env bash
# PACKAGE: tealdeer
# DESCRIPTION: Rust package from crates.io
# CATEGORY: dev
# UBUNTU_PKG: cargo:tealdeer
# ARCH_PKG: pacman:tealdeer
# NIX_PKG: nixpkgs.tealdeer
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing tealdeer..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "tealdeer"; then
                log "tealdeer is already installed"
                return 0
            fi
            install_package "cargo:tealdeer"
            ;;
        arch)
            if is_package_installed "tealdeer"; then
                log "tealdeer is already installed"
                return 0
            fi
            install_package "pacman:tealdeer"
            ;;
        nixos)
            log "For NixOS, add 'tealdeer' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "tealdeer installation complete"
}

main "$@"
