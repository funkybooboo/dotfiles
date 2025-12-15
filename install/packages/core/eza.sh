#!/usr/bin/env bash
# PACKAGE: eza
# DESCRIPTION: Package from APT repository
# CATEGORY: core
# UBUNTU_PKG: apt:eza
# ARCH_PKG: pacman:eza
# NIX_PKG: nixpkgs.eza
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing eza..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "eza"; then
                log "eza is already installed"
                return 0
            fi
            install_package "apt:eza"
            ;;
        arch)
            if is_package_installed "eza"; then
                log "eza is already installed"
                return 0
            fi
            install_package "pacman:eza"
            ;;
        nixos)
            log "For NixOS, add 'eza' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "eza installation complete"
}

main "$@"
