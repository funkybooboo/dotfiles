#!/usr/bin/env bash
# PACKAGE: fzf
# DESCRIPTION: Package from APT repository
# CATEGORY: core
# UBUNTU_PKG: apt:fzf
# ARCH_PKG: pacman:fzf
# NIX_PKG: nixpkgs.fzf
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing fzf..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "fzf"; then
                log "fzf is already installed"
                return 0
            fi
            install_package "apt:fzf"
            ;;
        arch)
            if is_package_installed "fzf"; then
                log "fzf is already installed"
                return 0
            fi
            install_package "pacman:fzf"
            ;;
        nixos)
            log "For NixOS, add 'fzf' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "fzf installation complete"
}

main "$@"
