#!/usr/bin/env bash
# PACKAGE: git-remote-gcrypt
# DESCRIPTION: Package from APT repository
# CATEGORY: core
# UBUNTU_PKG: apt:git-remote-gcrypt
# ARCH_PKG: pacman:git-remote-gcrypt
# NIX_PKG: nixpkgs.git-remote-gcrypt
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing git-remote-gcrypt..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "git-remote-gcrypt"; then
                log "git-remote-gcrypt is already installed"
                return 0
            fi
            install_package "apt:git-remote-gcrypt"
            ;;
        arch)
            if is_package_installed "git-remote-gcrypt"; then
                log "git-remote-gcrypt is already installed"
                return 0
            fi
            install_package "pacman:git-remote-gcrypt"
            ;;
        nixos)
            log "For NixOS, add 'git-remote-gcrypt' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "git-remote-gcrypt installation complete"
}

main "$@"
