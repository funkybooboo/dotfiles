#!/usr/bin/env bash
# PACKAGE: dust
# DESCRIPTION: More intuitive version of du in rust
# CATEGORY: core
# UBUNTU_PKG: apt:dust
# ARCH_PKG: pacman:dust
# NIX_PKG: nixpkgs.dust
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing dust..."

    # Skip if already installed
    if is_package_installed "dust"; then
        log "dust is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt:dust"
            ;;
        arch)
            install_package "pacman:dust"
            ;;
        nixos)
            log "For NixOS, add 'dust' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "dust installation complete"
}

main "$@"
