#!/usr/bin/env bash
# PACKAGE: tree-sitter-cli
# DESCRIPTION: CLI tool for developing, testing, and using Tree-sitter parsers
# CATEGORY: dev
# UBUNTU_PKG: npm:tree-sitter-cli
# ARCH_PKG: pacman:tree-sitter-cli
# NIX_PKG: nixpkgs.tree-sitter
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing tree-sitter-cli..."

    # Skip if already installed
    if is_package_installed "tree-sitter-cli" || command -v tree-sitter &>/dev/null; then
        log "tree-sitter-cli is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            # On Ubuntu, install via npm
            if ! command -v npm &>/dev/null; then
                log "ERROR: npm is required for tree-sitter-cli on Ubuntu"
                log "Please run node installer first"
                return 1
            fi

            log "Installing tree-sitter-cli via npm..."
            npm install -g tree-sitter-cli
            ;;
        arch)
            install_package "pacman:tree-sitter-cli"
            ;;
        nixos)
            log "For NixOS, add 'tree-sitter' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "tree-sitter-cli installation complete"
}

main "$@"
