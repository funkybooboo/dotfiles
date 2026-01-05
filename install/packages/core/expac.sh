#!/usr/bin/env bash
# PACKAGE: expac
# DESCRIPTION: Pacman database extraction utility
# CATEGORY: core
# UBUNTU_PKG: N/A
# ARCH_PKG: pacman\
# NIX_PKG: expac:N/A
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing expac..."

    # Skip if already installed
    if is_package_installed "expac"; then
        log "expac is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            log "ERROR: expac not available in Ubuntu repos"
return 1
            ;;
        arch)
            install_package "pacman\"
            ;;
        nixos)
            log "For NixOS, add 'expac:N/A' to environment.systemPackages in configuration.nix"
log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "expac installation complete"
}

main "$@"
