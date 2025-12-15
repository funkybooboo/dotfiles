#!/usr/bin/env bash
# PACKAGE: claude-code
# DESCRIPTION: NPM package
# CATEGORY: dev
# UBUNTU_PKG: npm:@anthropic-ai/claude-code
# ARCH_PKG: pacman:claude-code
# NIX_PKG: nixpkgs.claude-code
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing claude-code..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "claude-code"; then
                log "claude-code is already installed"
                return 0
            fi
            install_package "npm:@anthropic-ai/claude-code"
            ;;
        arch)
            if is_package_installed "claude-code"; then
                log "claude-code is already installed"
                return 0
            fi
            install_package "pacman:claude-code"
            ;;
        nixos)
            log "For NixOS, add 'claude-code' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "claude-code installation complete"
}

main "$@"
