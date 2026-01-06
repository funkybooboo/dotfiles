#!/usr/bin/env bash
# PACKAGE: openbsd-netcat
# DESCRIPTION: TCP/IP swiss army knife. OpenBSD variant.
# CATEGORY: core
# UBUNTU_PKG: apt:netcat-openbsd
# ARCH_PKG: pacman:openbsd-netcat
# NIX_PKG: nixpkgs.netcat-openbsd
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing openbsd-netcat..."

    # Skip if already installed
    if is_package_installed "openbsd-netcat" || is_package_installed "netcat-openbsd"; then
        log "openbsd-netcat is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt:netcat-openbsd"
            ;;
        arch)
            install_package "pacman:openbsd-netcat"
            ;;
        nixos)
            log "For NixOS, add 'netcat-openbsd' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "openbsd-netcat installation complete"
}

main "$@"
