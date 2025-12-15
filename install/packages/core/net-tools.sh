#!/usr/bin/env bash
# PACKAGE: net-tools
# DESCRIPTION: Package from APT repository
# CATEGORY: core
# UBUNTU_PKG: apt:net-tools
# ARCH_PKG: pacman:net-tools
# NIX_PKG: nixpkgs.net-tools
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing net-tools..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "net-tools"; then
                log "net-tools is already installed"
                return 0
            fi
            install_package "apt:net-tools"
            ;;
        arch)
            if is_package_installed "net-tools"; then
                log "net-tools is already installed"
                return 0
            fi
            install_package "pacman:net-tools"
            ;;
        nixos)
            log "For NixOS, add 'net-tools' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "net-tools installation complete"
}

main "$@"
