#!/usr/bin/env bash
# PACKAGE: swayosd
# DESCRIPTION: On-screen display for volume and brightness changes
# CATEGORY: desktop
# UBUNTU_PKG:
# ARCH_PKG: pacman:swayosd
# NIX_PKG: nixpkgs.swayosd
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing swayosd..."

    # Skip if already installed
    if is_package_installed "swayosd"; then
        log "swayosd is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            log "ERROR: swayosd not available in Ubuntu repos, build from source"
            return 1
            ;;
        arch)
            install_package "pacman:swayosd"
            ;;
        nixos)
            log "For NixOS, add 'swayosd' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "swayosd installation complete"
}

main "$@"
