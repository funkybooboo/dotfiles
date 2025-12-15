#!/usr/bin/env bash
# PACKAGE: nala
# DESCRIPTION: Package from Pacstall repository
# CATEGORY: dev
# UBUNTU_PKG: pacstall:nala-deb
# ARCH_PKG: pacman:nala
# NIX_PKG: nixpkgs.nala
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing nala..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "nala"; then
                log "nala is already installed"
                return 0
            fi
            install_package "pacstall:nala-deb"
            ;;
        arch)
            if is_package_installed "nala"; then
                log "nala is already installed"
                return 0
            fi
            install_package "pacman:nala"
            ;;
        nixos)
            log "For NixOS, add 'nala' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "nala installation complete"
}

main "$@"
