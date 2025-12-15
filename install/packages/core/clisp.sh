#!/usr/bin/env bash
# PACKAGE: clisp
# DESCRIPTION: Package from APT repository
# CATEGORY: core
# UBUNTU_PKG: apt:clisp
# ARCH_PKG: pacman:clisp
# NIX_PKG: nixpkgs.clisp
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing clisp..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "clisp"; then
                log "clisp is already installed"
                return 0
            fi
            install_package "apt:clisp"
            ;;
        arch)
            if is_package_installed "clisp"; then
                log "clisp is already installed"
                return 0
            fi
            install_package "pacman:clisp"
            ;;
        nixos)
            log "For NixOS, add 'clisp' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "clisp installation complete"
}

main "$@"
