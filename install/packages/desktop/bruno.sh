#!/usr/bin/env bash
# PACKAGE: bruno
# DESCRIPTION: Package from Snap store
# CATEGORY: desktop
# UBUNTU_PKG: snap:bruno
# ARCH_PKG: pacman:bruno
# NIX_PKG: nixpkgs.bruno
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing bruno..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "bruno"; then
                log "bruno is already installed"
                return 0
            fi
            install_package "snap:bruno"
            ;;
        arch)
            if is_package_installed "bruno"; then
                log "bruno is already installed"
                return 0
            fi
            install_package "pacman:bruno"
            ;;
        nixos)
            log "For NixOS, add 'bruno' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "bruno installation complete"
}

main "$@"
