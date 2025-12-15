#!/usr/bin/env bash
# PACKAGE: bat
# DESCRIPTION: A cat clone with syntax highlighting and Git integration
# CATEGORY: core
# UBUNTU_PKG: apt:bat
# ARCH_PKG: pacman:bat
# NIX_PKG: nixpkgs.bat
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing bat..."

    # Skip if already installed
    if is_package_installed "bat"; then
        log "bat is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt:bat"
            ;;
        arch)
            install_package "pacman:bat"
            ;;
        nixos)
            log "For NixOS, add 'bat' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "bat installation complete"
}

main "$@"
