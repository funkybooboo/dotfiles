#!/usr/bin/env bash
# PACKAGE: pandoc
# DESCRIPTION: Package from APT repository
# CATEGORY: core
# UBUNTU_PKG: apt:pandoc
# ARCH_PKG: pacman:pandoc
# NIX_PKG: nixpkgs.pandoc
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing pandoc..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "pandoc"; then
                log "pandoc is already installed"
                return 0
            fi
            install_package "apt:pandoc"
            ;;
        arch)
            if is_package_installed "pandoc"; then
                log "pandoc is already installed"
                return 0
            fi
            install_package "pacman:pandoc"
            ;;
        nixos)
            log "For NixOS, add 'pandoc' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "pandoc installation complete"
}

main "$@"
