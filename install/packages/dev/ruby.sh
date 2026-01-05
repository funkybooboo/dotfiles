#!/usr/bin/env bash
# PACKAGE: ruby
# DESCRIPTION: Object-oriented interpreted scripting language
# CATEGORY: dev
# UBUNTU_PKG: apt:ruby
# ARCH_PKG: pacman:ruby
# NIX_PKG: nixpkgs.ruby
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing ruby..."

    # Skip if already installed
    if is_package_installed "ruby"; then
        log "ruby is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt:ruby"
            ;;
        arch)
            install_package "pacman:ruby"
            ;;
        nixos)
            log "For NixOS, add 'ruby' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "ruby installation complete"
}

main "$@"
