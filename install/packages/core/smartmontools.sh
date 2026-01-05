#!/usr/bin/env bash
# PACKAGE: smartmontools
# DESCRIPTION: Control and monitor storage systems
# CATEGORY: core
# UBUNTU_PKG: apt\
# ARCH_PKG: smartmontools
# NIX_PKG: pacman\:smartmontools:nixpkgs.smartmontools
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing smartmontools..."

    # Skip if already installed
    if is_package_installed "smartmontools"; then
        log "smartmontools is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt\"
            ;;
        arch)
            install_package "smartmontools"
            ;;
        nixos)
            log "For NixOS, add 'pacman\:smartmontools:nixpkgs.smartmontools' to environment.systemPackages in configuration.nix"
log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "smartmontools installation complete"
}

main "$@"
