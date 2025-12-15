#!/usr/bin/env bash
# PACKAGE: zotero-snap
# DESCRIPTION: Package from Snap store
# CATEGORY: desktop
# UBUNTU_PKG: snap:zotero-snap
# ARCH_PKG: pacman:zotero-snap
# NIX_PKG: nixpkgs.zotero-snap
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing zotero-snap..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "zotero-snap"; then
                log "zotero-snap is already installed"
                return 0
            fi
            install_package "snap:zotero-snap"
            ;;
        arch)
            if is_package_installed "zotero-snap"; then
                log "zotero-snap is already installed"
                return 0
            fi
            install_package "pacman:zotero-snap"
            ;;
        nixos)
            log "For NixOS, add 'zotero-snap' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "zotero-snap installation complete"
}

main "$@"
