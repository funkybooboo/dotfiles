#!/usr/bin/env bash
# PACKAGE: obsidian
# DESCRIPTION: Package from Pacstall repository
# CATEGORY: dev
# UBUNTU_PKG: pacstall:obsidian-deb
# ARCH_PKG: yay:obsidian
# NIX_PKG: nixpkgs.obsidian
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing obsidian..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "obsidian"; then
                log "obsidian is already installed"
                return 0
            fi
            install_package "pacstall:obsidian-deb"
            ;;
        arch)
            if is_package_installed "obsidian"; then
                log "obsidian is already installed"
                return 0
            fi
            install_package "yay:obsidian"
            ;;
        nixos)
            log "For NixOS, add 'obsidian' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "obsidian installation complete"
}

main "$@"
