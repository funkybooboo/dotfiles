#!/usr/bin/env bash
# PACKAGE: curl
# DESCRIPTION: Package from APT repository
# CATEGORY: core
# UBUNTU_PKG: apt:curl
# ARCH_PKG: pacman:curl
# NIX_PKG: nixpkgs.curl
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing curl..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "curl"; then
                log "curl is already installed"
                return 0
            fi
            install_package "apt:curl"
            ;;
        arch)
            if is_package_installed "curl"; then
                log "curl is already installed"
                return 0
            fi
            install_package "pacman:curl"
            ;;
        nixos)
            log "For NixOS, add 'curl' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "curl installation complete"
}

main "$@"
