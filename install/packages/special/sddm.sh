#!/usr/bin/env bash
# PACKAGE: sddm
# DESCRIPTION: QML-based display manager
# CATEGORY: special
# UBUNTU_PKG: apt\
# ARCH_PKG: sddm
# NIX_PKG: pacman\:sddm:nixpkgs.sddm
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing sddm..."

    # Skip if already installed
    if is_package_installed "sddm"; then
        log "sddm is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt\"
            ;;
        arch)
            install_package "sddm"
            ;;
        nixos)
            log "For NixOS, add 'pacman\:sddm:nixpkgs.sddm' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "sddm installation complete"
}

main "$@"
