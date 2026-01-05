#!/usr/bin/env bash
# PACKAGE: tldr
# DESCRIPTION: Simplified and community-driven man pages
# CATEGORY: core
# UBUNTU_PKG: apt:tldr
# ARCH_PKG: pacman:tldr
# NIX_PKG: nixpkgs.tldr
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing tldr..."

    # Skip if already installed
    if is_package_installed "tldr"; then
        log "tldr is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt:tldr"
            ;;
        arch)
            install_package "pacman:tldr"
            ;;
        nixos)
            log "For NixOS, add 'tldr' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "tldr installation complete"
}

main "$@"
