#!/usr/bin/env bash
# PACKAGE: keepassxc
# DESCRIPTION: Package from Snap store
# CATEGORY: desktop
# UBUNTU_PKG: snap:keepassxc
# ARCH_PKG: pacman:keepassxc
# NIX_PKG: nixpkgs.keepassxc
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing keepassxc..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "keepassxc"; then
                log "keepassxc is already installed"
                return 0
            fi
            install_package "snap:keepassxc"
            ;;
        arch)
            if is_package_installed "keepassxc"; then
                log "keepassxc is already installed"
                return 0
            fi
            install_package "pacman:keepassxc"
            ;;
        nixos)
            log "For NixOS, add 'keepassxc' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "keepassxc installation complete"
}

main "$@"
