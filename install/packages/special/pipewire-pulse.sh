#!/usr/bin/env bash
# PACKAGE: pipewire-pulse
# DESCRIPTION: PulseAudio replacement
# CATEGORY: special
# UBUNTU_PKG: apt\
# ARCH_PKG: pipewire-pulse
# NIX_PKG: pacman\:pipewire-pulse:nixpkgs.pipewire.pulse
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing pipewire-pulse..."

    # Skip if already installed
    if is_package_installed "pipewire-pulse"; then
        log "pipewire-pulse is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt\"
            ;;
        arch)
            install_package "pipewire-pulse"
            ;;
        nixos)
            log "For NixOS, add 'pacman\:pipewire-pulse:nixpkgs.pipewire.pulse' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "pipewire-pulse installation complete"
}

main "$@"
