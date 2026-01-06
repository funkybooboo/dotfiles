#!/usr/bin/env bash
# PACKAGE: sshpass
# DESCRIPTION: Fool ssh into accepting an interactive password non-interactively
# CATEGORY: core
# UBUNTU_PKG: apt:sshpass
# ARCH_PKG: pacman:sshpass
# NIX_PKG: nixpkgs.sshpass
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing sshpass..."

    # Skip if already installed
    if is_package_installed "sshpass"; then
        log "sshpass is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt:sshpass"
            ;;
        arch)
            install_package "pacman:sshpass"
            ;;
        nixos)
            log "For NixOS, add 'sshpass' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "sshpass installation complete"
}

main "$@"
