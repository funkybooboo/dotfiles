#!/usr/bin/env bash
# PACKAGE: git
# DESCRIPTION: Package from APT repository
# CATEGORY: core
# UBUNTU_PKG: apt:git
# ARCH_PKG: pacman:git
# NIX_PKG: nixpkgs.git
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing git..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "git"; then
                log "git is already installed"
                return 0
            fi
            install_package "apt:git"
            ;;
        arch)
            if is_package_installed "git"; then
                log "git is already installed"
                return 0
            fi
            install_package "pacman:git"
            ;;
        nixos)
            log "For NixOS, add 'git' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "git installation complete"
}

main "$@"
