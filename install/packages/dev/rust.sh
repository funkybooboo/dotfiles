#!/usr/bin/env bash
# PACKAGE: rust
# DESCRIPTION: Systems programming language focused on safety and performance
# CATEGORY: dev
# UBUNTU_PKG:
# ARCH_PKG: pacman:rust
# NIX_PKG: nixpkgs.rustc nixpkgs.cargo
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing rust..."

    # Skip if already installed
    if is_package_installed "rust"; then
        log "rust is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            log "Installing rust via rustup..."
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
            source "$HOME/.cargo/env"
            ;;
        arch)
            install_package "pacman:rust"
            ;;
        nixos)
            log "For NixOS, add to environment.systemPackages in configuration.nix:"
            log "  rustc"
            log "  cargo"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "rust installation complete"
}

main "$@"
