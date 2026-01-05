#!/usr/bin/env bash
# PACKAGE: dosfstools
# DESCRIPTION: DOS filesystem utilities
# CATEGORY: core
# UBUNTU_PKG: apt\
# ARCH_PKG: dosfstools
# NIX_PKG: pacman\:dosfstools:nixpkgs.dosfstools
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing dosfstools..."

    # Skip if already installed
    if is_package_installed "dosfstools"; then
        log "dosfstools is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt\"
            ;;
        arch)
            install_package "dosfstools"
            ;;
        nixos)
            log "For NixOS, add 'pacman\:dosfstools:nixpkgs.dosfstools' to environment.systemPackages in configuration.nix"
log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "dosfstools installation complete"
}

main "$@"
