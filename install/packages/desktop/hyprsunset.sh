#!/usr/bin/env bash
# PACKAGE: hyprsunset
# DESCRIPTION: Hyprland blue light filter
# CATEGORY: desktop
# UBUNTU_PKG:
# ARCH_PKG: pacman:hyprsunset
# NIX_PKG: nixpkgs.hyprsunset
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing hyprsunset..."

    # Skip if already installed
    if is_package_installed "hyprsunset"; then
        log "hyprsunset is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            log "ERROR: hyprsunset not available in Ubuntu repos, build from source"
            return 1
            ;;
        arch)
            install_package "pacman:hyprsunset"
            ;;
        nixos)
            log "For NixOS, add 'hyprsunset' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "hyprsunset installation complete"
}

main "$@"
