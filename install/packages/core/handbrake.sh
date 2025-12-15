#!/usr/bin/env bash
# PACKAGE: handbrake
# DESCRIPTION: Package from APT repository
# CATEGORY: core
# UBUNTU_PKG: apt:handbrake
# ARCH_PKG: pacman:handbrake
# NIX_PKG: nixpkgs.handbrake
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing handbrake..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "handbrake"; then
                log "handbrake is already installed"
                return 0
            fi
            install_package "apt:handbrake"
            ;;
        arch)
            if is_package_installed "handbrake"; then
                log "handbrake is already installed"
                return 0
            fi
            install_package "pacman:handbrake"
            ;;
        nixos)
            log "For NixOS, add 'handbrake' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "handbrake installation complete"
}

main "$@"
