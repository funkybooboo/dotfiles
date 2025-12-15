#!/usr/bin/env bash
# PACKAGE: termshark
# DESCRIPTION: Package from APT repository
# CATEGORY: core
# UBUNTU_PKG: apt:termshark
# ARCH_PKG: pacman:termshark
# NIX_PKG: nixpkgs.termshark
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing termshark..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "termshark"; then
                log "termshark is already installed"
                return 0
            fi
            install_package "apt:termshark"
            ;;
        arch)
            if is_package_installed "termshark"; then
                log "termshark is already installed"
                return 0
            fi
            install_package "pacman:termshark"
            ;;
        nixos)
            log "For NixOS, add 'termshark' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "termshark installation complete"
}

main "$@"
