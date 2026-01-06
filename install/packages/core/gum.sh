#!/usr/bin/env bash
# PACKAGE: gum
# DESCRIPTION: A tool for glamorous shell scripts
# CATEGORY: core
# UBUNTU_PKG: go:github.com/charmbracelet/gum@latest
# ARCH_PKG: pacman:gum
# NIX_PKG: nixpkgs.gum
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing gum..."

    # Skip if already installed
    if command -v gum &>/dev/null; then
        log "gum is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            # On Ubuntu, install via go
            if ! command -v go &>/dev/null; then
                log "ERROR: Go is required for gum on Ubuntu"
                log "Please run go installer first"
                return 1
            fi

            log "Installing gum via go..."
            go install github.com/charmbracelet/gum@latest
            ;;
        arch)
            install_package "pacman:gum"
            ;;
        nixos)
            log "For NixOS, add 'gum' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "gum installation complete"
}

main "$@"
