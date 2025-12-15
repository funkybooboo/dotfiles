#!/usr/bin/env bash
# PACKAGE: errno
# DESCRIPTION: Package from APT repository
# CATEGORY: core
# UBUNTU_PKG: apt:errno
# ARCH_PKG: pacman:errno
# NIX_PKG: nixpkgs.errno
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing errno..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "errno"; then
                log "errno is already installed"
                return 0
            fi
            install_package "apt:errno"
            ;;
        arch)
            if is_package_installed "errno"; then
                log "errno is already installed"
                return 0
            fi
            install_package "pacman:errno"
            ;;
        nixos)
            log "For NixOS, add 'errno' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "errno installation complete"
}

main "$@"
