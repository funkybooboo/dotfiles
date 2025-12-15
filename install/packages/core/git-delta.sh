#!/usr/bin/env bash
# PACKAGE: git-delta
# DESCRIPTION: Package from APT repository
# CATEGORY: core
# UBUNTU_PKG: apt:git-delta
# ARCH_PKG: pacman:git-delta
# NIX_PKG: nixpkgs.git-delta
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing git-delta..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "git-delta"; then
                log "git-delta is already installed"
                return 0
            fi
            install_package "apt:git-delta"
            ;;
        arch)
            if is_package_installed "git-delta"; then
                log "git-delta is already installed"
                return 0
            fi
            install_package "pacman:git-delta"
            ;;
        nixos)
            log "For NixOS, add 'git-delta' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "git-delta installation complete"
}

main "$@"
