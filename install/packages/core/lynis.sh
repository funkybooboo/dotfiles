#!/usr/bin/env bash
# PACKAGE: lynis
# DESCRIPTION: Package from APT repository
# CATEGORY: core
# UBUNTU_PKG: apt:lynis
# ARCH_PKG: pacman:lynis
# NIX_PKG: nixpkgs.lynis
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing lynis..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "lynis"; then
                log "lynis is already installed"
                return 0
            fi
            install_package "apt:lynis"
            ;;
        arch)
            if is_package_installed "lynis"; then
                log "lynis is already installed"
                return 0
            fi
            install_package "pacman:lynis"
            ;;
        nixos)
            log "For NixOS, add 'lynis' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "lynis installation complete"
}

main "$@"
