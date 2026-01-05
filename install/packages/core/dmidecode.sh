#!/usr/bin/env bash
# PACKAGE: dmidecode
# DESCRIPTION: Desktop Management Interface table decoder
# CATEGORY: core
# UBUNTU_PKG: apt\
# ARCH_PKG: dmidecode
# NIX_PKG: pacman\:dmidecode:nixpkgs.dmidecode
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing dmidecode..."

    # Skip if already installed
    if is_package_installed "dmidecode"; then
        log "dmidecode is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt\"
            ;;
        arch)
            install_package "dmidecode"
            ;;
        nixos)
            log "For NixOS, add 'pacman\:dmidecode:nixpkgs.dmidecode' to environment.systemPackages in configuration.nix"
log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "dmidecode installation complete"
}

main "$@"
