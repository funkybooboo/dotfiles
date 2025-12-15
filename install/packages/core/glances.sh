#!/usr/bin/env bash
# PACKAGE: glances
# DESCRIPTION: Package from APT repository
# CATEGORY: core
# UBUNTU_PKG: apt:glances
# ARCH_PKG: pacman:glances
# NIX_PKG: nixpkgs.glances
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing glances..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "glances"; then
                log "glances is already installed"
                return 0
            fi
            install_package "apt:glances"
            ;;
        arch)
            if is_package_installed "glances"; then
                log "glances is already installed"
                return 0
            fi
            install_package "pacman:glances"
            ;;
        nixos)
            log "For NixOS, add 'glances' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "glances installation complete"
}

main "$@"
