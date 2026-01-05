#!/usr/bin/env bash
# PACKAGE: fastfetch
# DESCRIPTION: Fast neofetch-like system information tool
# CATEGORY: core
# UBUNTU_PKG:
# ARCH_PKG: pacman:fastfetch
# NIX_PKG: nixpkgs.fastfetch
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing fastfetch..."

    # Skip if already installed
    if is_package_installed "fastfetch"; then
        log "fastfetch is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            log "Installing fastfetch via PPA..."
            sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch
            sudo apt update
            install_package "apt:fastfetch"
            ;;
        arch)
            install_package "pacman:fastfetch"
            ;;
        nixos)
            log "For NixOS, add 'fastfetch' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "fastfetch installation complete"
}

main "$@"
