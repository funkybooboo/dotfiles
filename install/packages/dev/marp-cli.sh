#!/usr/bin/env bash
# PACKAGE: marp-cli
# DESCRIPTION: NPM package
# CATEGORY: dev
# UBUNTU_PKG: npm:@marp-team/marp-cli
# ARCH_PKG: pacman:marp-cli
# NIX_PKG: nixpkgs.marp-cli
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing marp-cli..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "marp-cli"; then
                log "marp-cli is already installed"
                return 0
            fi
            install_package "npm:@marp-team/marp-cli"
            ;;
        arch)
            if is_package_installed "marp-cli"; then
                log "marp-cli is already installed"
                return 0
            fi
            install_package "pacman:marp-cli"
            ;;
        nixos)
            log "For NixOS, add 'marp-cli' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "marp-cli installation complete"
}

main "$@"
