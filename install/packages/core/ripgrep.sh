#!/usr/bin/env bash
# PACKAGE: ripgrep
# DESCRIPTION: Package from APT repository
# CATEGORY: core
# UBUNTU_PKG: apt:ripgrep
# ARCH_PKG: pacman:ripgrep
# NIX_PKG: nixpkgs.ripgrep
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing ripgrep..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "ripgrep"; then
                log "ripgrep is already installed"
                return 0
            fi
            install_package "apt:ripgrep"
            ;;
        arch)
            if is_package_installed "ripgrep"; then
                log "ripgrep is already installed"
                return 0
            fi
            install_package "pacman:ripgrep"
            ;;
        nixos)
            log "For NixOS, add 'ripgrep' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "ripgrep installation complete"
}

main "$@"
