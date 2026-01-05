#!/usr/bin/env bash
# PACKAGE: docker-buildx
# DESCRIPTION: Docker CLI plugin for extended build capabilities
# CATEGORY: dev
# UBUNTU_PKG: apt:docker-buildx
# ARCH_PKG: pacman:docker-buildx
# NIX_PKG: nixpkgs.docker-buildx
# DEPENDS: docker
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing docker-buildx..."

    # Skip if already installed
    if is_package_installed "docker-buildx"; then
        log "docker-buildx is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt:docker-buildx-plugin"
            ;;
        arch)
            install_package "pacman:docker-buildx"
            ;;
        nixos)
            log "For NixOS, add 'docker-buildx' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "docker-buildx installation complete"
}

main "$@"
