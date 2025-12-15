#!/usr/bin/env bash
# PACKAGE: python3-poetry
# DESCRIPTION: Package from APT repository
# CATEGORY: core
# UBUNTU_PKG: apt:python3-poetry
# ARCH_PKG: pacman:python3-poetry
# NIX_PKG: nixpkgs.poetry
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing python3-poetry..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "python3-poetry"; then
                log "python3-poetry is already installed"
                return 0
            fi
            install_package "apt:python3-poetry"
            ;;
        arch)
            if is_package_installed "python3-poetry"; then
                log "python3-poetry is already installed"
                return 0
            fi
            install_package "pacman:python3-poetry"
            ;;
        nixos)
            log "For NixOS, add 'poetry' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "python3-poetry installation complete"
}

main "$@"
