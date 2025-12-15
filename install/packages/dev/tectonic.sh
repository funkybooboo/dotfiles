#!/usr/bin/env bash
# PACKAGE: tectonic
# DESCRIPTION: Package from Nix repository
# CATEGORY: dev
# UBUNTU_PKG: nix:tectonic
# ARCH_PKG: pacman:tectonic
# NIX_PKG: nixpkgs.tectonic
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing tectonic..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "tectonic"; then
                log "tectonic is already installed"
                return 0
            fi
            install_package "nix:tectonic"
            ;;
        arch)
            if is_package_installed "tectonic"; then
                log "tectonic is already installed"
                return 0
            fi
            install_package "pacman:tectonic"
            ;;
        nixos)
            log "For NixOS, add 'tectonic' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "tectonic installation complete"
}

main "$@"
