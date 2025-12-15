#!/usr/bin/env bash
# PACKAGE: mpv
# DESCRIPTION: Package from APT repository
# CATEGORY: core
# UBUNTU_PKG: apt:mpv
# ARCH_PKG: pacman:mpv
# NIX_PKG: nixpkgs.mpv
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing mpv..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "mpv"; then
                log "mpv is already installed"
                return 0
            fi
            install_package "apt:mpv"
            ;;
        arch)
            if is_package_installed "mpv"; then
                log "mpv is already installed"
                return 0
            fi
            install_package "pacman:mpv"
            ;;
        nixos)
            log "For NixOS, add 'mpv' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "mpv installation complete"
}

main "$@"
