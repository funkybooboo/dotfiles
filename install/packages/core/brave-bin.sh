#!/usr/bin/env bash
# PACKAGE: brave-bin
# DESCRIPTION: Brave web browser (privacy-focused)
# CATEGORY: core
# UBUNTU_PKG:
# ARCH_PKG: aur:brave-bin
# NIX_PKG: nixpkgs.brave
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing brave-bin..."

    # Skip if already installed
    if is_package_installed "brave-bin"; then
        log "brave-bin is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            log "Adding Brave repository..."
            sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
            echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
            sudo apt update
            install_package "apt:brave-browser"
            ;;
        arch)
            install_package "aur:brave-bin"
            ;;
        nixos)
            log "For NixOS, add 'brave' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "brave-bin installation complete"
}

main "$@"
