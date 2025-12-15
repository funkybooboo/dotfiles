#!/usr/bin/env bash
# PACKAGE: oathtool
# DESCRIPTION: Package from APT repository
# CATEGORY: core
# UBUNTU_PKG: apt:oathtool
# ARCH_PKG: pacman:oathtool
# NIX_PKG: nixpkgs.oathtool
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing oathtool..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "oathtool"; then
                log "oathtool is already installed"
                return 0
            fi
            install_package "apt:oathtool"
            ;;
        arch)
            if is_package_installed "oathtool"; then
                log "oathtool is already installed"
                return 0
            fi
            install_package "pacman:oathtool"
            ;;
        nixos)
            log "For NixOS, add 'oathtool' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "oathtool installation complete"
}

main "$@"
