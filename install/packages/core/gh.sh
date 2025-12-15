#!/usr/bin/env bash
# PACKAGE: gh
# DESCRIPTION: Package from APT repository
# CATEGORY: core
# UBUNTU_PKG: apt:gh
# ARCH_PKG: pacman:gh
# NIX_PKG: nixpkgs.gh
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing gh..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "gh"; then
                log "gh is already installed"
                return 0
            fi
            install_package "apt:gh"
            ;;
        arch)
            if is_package_installed "gh"; then
                log "gh is already installed"
                return 0
            fi
            install_package "pacman:gh"
            ;;
        nixos)
            log "For NixOS, add 'gh' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "gh installation complete"
}

main "$@"
