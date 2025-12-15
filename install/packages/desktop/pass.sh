#!/usr/bin/env bash
# PACKAGE: pass
# DESCRIPTION: Package from Flathub
# CATEGORY: desktop
# UBUNTU_PKG: flatpak:me.proton.Pass
# ARCH_PKG: pacman:pass
# NIX_PKG: nixpkgs.pass
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing pass..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "pass"; then
                log "pass is already installed"
                return 0
            fi
            install_package "flatpak:me.proton.Pass"
            ;;
        arch)
            if is_package_installed "pass"; then
                log "pass is already installed"
                return 0
            fi
            install_package "pacman:pass"
            ;;
        nixos)
            log "For NixOS, add 'pass' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "pass installation complete"
}

main "$@"
