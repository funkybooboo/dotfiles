#!/usr/bin/env bash
# PACKAGE: glow
# DESCRIPTION: Go package
# CATEGORY: dev
# UBUNTU_PKG: go:github.com/charmbracelet/glow@latest
# ARCH_PKG: pacman:glow
# NIX_PKG: nixpkgs.glow
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing glow..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "glow"; then
                log "glow is already installed"
                return 0
            fi
            install_package "go:github.com/charmbracelet/glow@latest"
            ;;
        arch)
            if is_package_installed "glow"; then
                log "glow is already installed"
                return 0
            fi
            install_package "pacman:glow"
            ;;
        nixos)
            log "For NixOS, add 'glow' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "glow installation complete"
}

main "$@"
