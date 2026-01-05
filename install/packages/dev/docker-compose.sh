#!/usr/bin/env bash
# PACKAGE: docker-compose
# DESCRIPTION: Define and run multi-container applications with Docker
# CATEGORY: dev
# UBUNTU_PKG: apt:docker-compose
# ARCH_PKG: pacman:docker-compose
# NIX_PKG: nixpkgs.docker-compose
# DEPENDS: docker
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing docker-compose..."

    # Skip if already installed
    if is_package_installed "docker-compose"; then
        log "docker-compose is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt:docker-compose"
            ;;
        arch)
            install_package "pacman:docker-compose"
            ;;
        nixos)
            log "For NixOS, add 'docker-compose' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "docker-compose installation complete"
}

main "$@"
