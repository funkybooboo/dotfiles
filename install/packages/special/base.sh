#!/usr/bin/env bash
# PACKAGE: base
# DESCRIPTION: Minimal package set to define a basic Arch Linux installation
# CATEGORY: special
# UBUNTU_PKG: N/A (Ubuntu equivalent is installed by default)
# ARCH_PKG: pacman:base
# NIX_PKG: N/A (NixOS equivalent is in base config)
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing base..."

    # Skip if already installed
    if is_package_installed "base"; then
        log "base is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            log "Ubuntu has base packages installed by default"
            return 0
            ;;
        arch)
            install_package "pacman:base"
            ;;
        nixos)
            log "NixOS base system is managed via configuration.nix"
            return 0
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "base installation complete"
}

main "$@"
