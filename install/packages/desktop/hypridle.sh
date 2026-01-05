#!/usr/bin/env bash
# PACKAGE: hypridle
# DESCRIPTION: Hyprland's idle daemon
# CATEGORY: desktop
# UBUNTU_PKG:
# ARCH_PKG: pacman:hypridle
# NIX_PKG: nixpkgs.hypridle
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing hypridle..."

    # Skip if already installed
    if is_package_installed "hypridle"; then
        log "hypridle is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            log "ERROR: hypridle not available in Ubuntu repos, build from source"
            return 1
            ;;
        arch)
            install_package "pacman:hypridle"
            ;;
        nixos)
            log "For NixOS, add 'hypridle' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "hypridle installation complete"
}

main "$@"
