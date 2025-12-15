#!/usr/bin/env bash
# PACKAGE: procps
# DESCRIPTION: Package from APT repository
# CATEGORY: core
# UBUNTU_PKG: apt:procps
# ARCH_PKG: pacman:procps
# NIX_PKG: nixpkgs.procps
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing procps..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "procps"; then
                log "procps is already installed"
                return 0
            fi
            install_package "apt:procps"
            ;;
        arch)
            if is_package_installed "procps"; then
                log "procps is already installed"
                return 0
            fi
            install_package "pacman:procps"
            ;;
        nixos)
            log "For NixOS, add 'procps' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "procps installation complete"
}

main "$@"
