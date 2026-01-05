#!/usr/bin/env bash
# PACKAGE: docker
# DESCRIPTION: Container runtime platform
# CATEGORY: dev
# UBUNTU_PKG: apt:docker.io
# ARCH_PKG: pacman:docker
# NIX_PKG: nixpkgs.docker
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing docker..."

    # Skip if already installed
    if is_package_installed "docker"; then
        log "docker is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt:docker.io"
            log "Adding user to docker group..."
            sudo usermod -aG docker "$USER"
            log "Enable and start docker service..."
            sudo systemctl enable docker
            sudo systemctl start docker
            ;;
        arch)
            install_package "pacman:docker"
            log "Adding user to docker group..."
            sudo usermod -aG docker "$USER"
            log "Enable and start docker service..."
            sudo systemctl enable docker.service
            sudo systemctl start docker.service
            ;;
        nixos)
            log "For NixOS, add to configuration.nix:"
            log "  virtualisation.docker.enable = true;"
            log "  users.users.<username>.extraGroups = [ \"docker\" ];"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "docker installation complete"
    log "NOTE: Log out and back in for group changes to take effect"
}

main "$@"
