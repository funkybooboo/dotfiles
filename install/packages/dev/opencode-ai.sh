#!/usr/bin/env bash
# PACKAGE: opencode-ai
# DESCRIPTION: NPM package
# CATEGORY: dev
# UBUNTU_PKG: npm:opencode-ai@latest
# ARCH_PKG: pacman:opencode-ai
# NIX_PKG: nixpkgs.opencode-ai
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing opencode-ai..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "opencode-ai"; then
                log "opencode-ai is already installed"
                return 0
            fi
            install_package "npm:opencode-ai@latest"
            ;;
        arch)
            if is_package_installed "opencode-ai"; then
                log "opencode-ai is already installed"
                return 0
            fi
            install_package "pacman:opencode-ai"
            ;;
        nixos)
            log "For NixOS, add 'opencode-ai' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "opencode-ai installation complete"
}

main "$@"
