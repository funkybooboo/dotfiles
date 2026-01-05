#!/usr/bin/env bash
# PACKAGE: hyprpicker
# DESCRIPTION: Wayland color picker for Hyprland
# CATEGORY: desktop
# UBUNTU_PKG:
# ARCH_PKG: pacman:hyprpicker
# NIX_PKG: nixpkgs.hyprpicker
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing hyprpicker..."

    # Skip if already installed
    if is_package_installed "hyprpicker"; then
        log "hyprpicker is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            log "ERROR: hyprpicker not available in Ubuntu repos, build from source"
            return 1
            ;;
        arch)
            install_package "pacman:hyprpicker"
            ;;
        nixos)
            log "For NixOS, add 'hyprpicker' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "hyprpicker installation complete"
}

main "$@"
