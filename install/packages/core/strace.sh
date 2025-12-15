#!/usr/bin/env bash
# PACKAGE: strace
# DESCRIPTION: Package from APT repository
# CATEGORY: core
# UBUNTU_PKG: apt:strace
# ARCH_PKG: pacman:strace
# NIX_PKG: nixpkgs.strace
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing strace..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "strace"; then
                log "strace is already installed"
                return 0
            fi
            install_package "apt:strace"
            ;;
        arch)
            if is_package_installed "strace"; then
                log "strace is already installed"
                return 0
            fi
            install_package "pacman:strace"
            ;;
        nixos)
            log "For NixOS, add 'strace' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "strace installation complete"
}

main "$@"
