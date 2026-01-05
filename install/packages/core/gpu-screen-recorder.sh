#!/usr/bin/env bash
# PACKAGE: gpu-screen-recorder
# DESCRIPTION: GPU-accelerated screen recorder for Linux
# CATEGORY: core
# UBUNTU_PKG:
# ARCH_PKG: aur:gpu-screen-recorder
# NIX_PKG: nixpkgs.gpu-screen-recorder
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing gpu-screen-recorder..."

    # Skip if already installed
    if is_package_installed "gpu-screen-recorder"; then
        log "gpu-screen-recorder is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            log "ERROR: gpu-screen-recorder not available in Ubuntu repos, build from source"
            return 1
            ;;
        arch)
            install_package "aur:gpu-screen-recorder"
            ;;
        nixos)
            log "For NixOS, add 'gpu-screen-recorder' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "gpu-screen-recorder installation complete"
}

main "$@"
