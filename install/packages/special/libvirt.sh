#!/usr/bin/env bash
# PACKAGE: libvirt
# DESCRIPTION: Virtualization API
# CATEGORY: special
# UBUNTU_PKG: apt\
# ARCH_PKG: libvirt-daemon-system
# NIX_PKG: pacman\:libvirt:nixpkgs.libvirt
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing libvirt..."

    # Skip if already installed
    if is_package_installed "libvirt"; then
        log "libvirt is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt\"
            ;;
        arch)
            install_package "libvirt-daemon-system"
            ;;
        nixos)
            log "For NixOS, add 'pacman\:libvirt:nixpkgs.libvirt' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "libvirt installation complete"
}

main "$@"
