#!/usr/bin/env bash
# PACKAGE: qemu-full
# DESCRIPTION: Full QEMU system emulator
# CATEGORY: special
# UBUNTU_PKG: apt\
# ARCH_PKG: qemu-system
# NIX_PKG: pacman\:qemu-full:nixpkgs.qemu
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing qemu-full..."

    # Skip if already installed
    if is_package_installed "qemu-full"; then
        log "qemu-full is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt\"
            ;;
        arch)
            install_package "qemu-system"
            ;;
        nixos)
            log "For NixOS, add 'pacman\:qemu-full:nixpkgs.qemu' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "qemu-full installation complete"
}

main "$@"
