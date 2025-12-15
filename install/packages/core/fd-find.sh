#!/usr/bin/env bash
# PACKAGE: fd-find
# DESCRIPTION: A simple, fast alternative to find
# CATEGORY: core
# UBUNTU_PKG: apt:fd-find
# ARCH_PKG: pacman:fd
# NIX_PKG: nixpkgs.fd
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing fd..."

    # Install based on distro (different package names)
    case "$DISTRO" in
        ubuntu)
            if is_package_installed "fd-find"; then
                log "fd-find is already installed"
                return 0
            fi
            install_package "apt:fd-find"
            ;;
        arch)
            if is_package_installed "fd"; then
                log "fd is already installed"
                return 0
            fi
            install_package "pacman:fd"
            ;;
        nixos)
            log "For NixOS, add 'fd' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "fd installation complete"
}

main "$@"
