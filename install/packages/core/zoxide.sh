#!/usr/bin/env bash
# PACKAGE: zoxide
# DESCRIPTION: Package from APT repository
# CATEGORY: core
# UBUNTU_PKG: apt:zoxide
# ARCH_PKG: pacman:zoxide
# NIX_PKG: nixpkgs.zoxide
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing zoxide..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "zoxide"; then
                log "zoxide is already installed"
                return 0
            fi
            install_package "apt:zoxide"
            ;;
        arch)
            if is_package_installed "zoxide"; then
                log "zoxide is already installed"
                return 0
            fi
            install_package "pacman:zoxide"
            ;;
        nixos)
            log "For NixOS, add 'zoxide' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "zoxide installation complete"
}

main "$@"
