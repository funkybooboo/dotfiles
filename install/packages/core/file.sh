#!/usr/bin/env bash
# PACKAGE: file
# DESCRIPTION: Package from APT repository
# CATEGORY: core
# UBUNTU_PKG: apt:file
# ARCH_PKG: pacman:file
# NIX_PKG: nixpkgs.file
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing file..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "file"; then
                log "file is already installed"
                return 0
            fi
            install_package "apt:file"
            ;;
        arch)
            if is_package_installed "file"; then
                log "file is already installed"
                return 0
            fi
            install_package "pacman:file"
            ;;
        nixos)
            log "For NixOS, add 'file' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "file installation complete"
}

main "$@"
