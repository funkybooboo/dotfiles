#!/usr/bin/env bash
# PACKAGE: browser
# DESCRIPTION: Package from Flathub
# CATEGORY: desktop
# UBUNTU_PKG: flatpak:com.brave.Browser
# ARCH_PKG: pacman:browser
# NIX_PKG: nixpkgs.browser
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing browser..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "browser"; then
                log "browser is already installed"
                return 0
            fi
            install_package "flatpak:com.brave.Browser"
            ;;
        arch)
            if is_package_installed "browser"; then
                log "browser is already installed"
                return 0
            fi
            install_package "pacman:browser"
            ;;
        nixos)
            log "For NixOS, add 'browser' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "browser installation complete"
}

main "$@"
