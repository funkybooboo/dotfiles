#!/usr/bin/env bash
# PACKAGE: clamav
# DESCRIPTION: Package from APT repository
# CATEGORY: core
# UBUNTU_PKG: apt:clamav
# ARCH_PKG: pacman:clamav
# NIX_PKG: nixpkgs.clamav
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing clamav..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "clamav"; then
                log "clamav is already installed"
                return 0
            fi
            install_package "apt:clamav"
            ;;
        arch)
            if is_package_installed "clamav"; then
                log "clamav is already installed"
                return 0
            fi
            install_package "pacman:clamav"
            ;;
        nixos)
            log "For NixOS, add 'clamav' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "clamav installation complete"
}

main "$@"
