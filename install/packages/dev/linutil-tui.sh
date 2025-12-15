#!/usr/bin/env bash
# PACKAGE: linutil-tui
# DESCRIPTION: Rust package from crates.io
# CATEGORY: dev
# UBUNTU_PKG: cargo:linutil_tui
# ARCH_PKG: pacman:linutil-tui
# NIX_PKG: nixpkgs.linutil-tui
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing linutil-tui..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "linutil-tui"; then
                log "linutil-tui is already installed"
                return 0
            fi
            install_package "cargo:linutil_tui"
            ;;
        arch)
            if is_package_installed "linutil-tui"; then
                log "linutil-tui is already installed"
                return 0
            fi
            install_package "pacman:linutil-tui"
            ;;
        nixos)
            log "For NixOS, add 'linutil-tui' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "linutil-tui installation complete"
}

main "$@"
