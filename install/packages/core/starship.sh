#!/usr/bin/env bash
# PACKAGE: starship
# DESCRIPTION: Minimal, fast, and customizable prompt for any shell
# CATEGORY: core
# UBUNTU_PKG:
# ARCH_PKG: pacman:starship
# NIX_PKG: nixpkgs.starship
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing starship..."

    # Skip if already installed
    if is_package_installed "starship"; then
        log "starship is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            log "Installing starship via install script..."
            curl -sS https://starship.rs/install.sh | sh -s -- -y
            ;;
        arch)
            install_package "pacman:starship"
            ;;
        nixos)
            log "For NixOS, add 'starship' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "starship installation complete"
    log "Add to your shell rc: eval \"\$(starship init bash)\""
}

main "$@"
