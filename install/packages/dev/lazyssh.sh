#!/usr/bin/env bash
# PACKAGE: lazyssh
# DESCRIPTION: Package from Homebrew
# CATEGORY: dev
# UBUNTU_PKG: brew:lazyssh
# ARCH_PKG: yay:lazyssh
# NIX_PKG: nixpkgs.lazyssh
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing lazyssh..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "lazyssh"; then
                log "lazyssh is already installed"
                return 0
            fi
            install_package "brew:lazyssh"
            ;;
        arch)
            if is_package_installed "lazyssh"; then
                log "lazyssh is already installed"
                return 0
            fi
            install_package "yay:lazyssh"
            ;;
        nixos)
            log "For NixOS, add 'lazyssh' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "lazyssh installation complete"
}

main "$@"
