#!/usr/bin/env bash
# PACKAGE: less
# DESCRIPTION: Less text pager
# CATEGORY: core
# UBUNTU_PKG: apt\
# ARCH_PKG: less
# NIX_PKG: pacman\:less:nixpkgs.less
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing less..."

    # Skip if already installed
    if is_package_installed "less"; then
        log "less is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt\"
            ;;
        arch)
            install_package "less"
            ;;
        nixos)
            log "For NixOS, add 'pacman\:less:nixpkgs.less' to environment.systemPackages in configuration.nix"
log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "less installation complete"
}

main "$@"
