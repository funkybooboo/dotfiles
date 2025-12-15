#!/usr/bin/env bash
# PACKAGE: tor
# DESCRIPTION: Package from APT repository
# CATEGORY: core
# UBUNTU_PKG: apt:tor
# ARCH_PKG: pacman:tor
# NIX_PKG: nixpkgs.tor
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing tor..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "tor"; then
                log "tor is already installed"
                return 0
            fi
            install_package "apt:tor"
            ;;
        arch)
            if is_package_installed "tor"; then
                log "tor is already installed"
                return 0
            fi
            install_package "pacman:tor"
            ;;
        nixos)
            log "For NixOS, add 'tor' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "tor installation complete"
}

main "$@"
