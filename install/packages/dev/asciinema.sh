#!/usr/bin/env bash
# PACKAGE: asciinema
# DESCRIPTION: Record and share your terminal sessions
# CATEGORY: dev
# UBUNTU_PKG: apt:asciinema
# ARCH_PKG: aur:asciinema-git
# NIX_PKG: nixpkgs.asciinema
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing asciinema..."

    # Skip if already installed
    if is_package_installed "asciinema" || is_package_installed "asciinema-git" || command -v asciinema &>/dev/null; then
        log "asciinema is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt:asciinema"
            ;;
        arch)
            # Install git version from AUR for latest features
            install_package "aur:asciinema-git"
            ;;
        nixos)
            log "For NixOS, add 'asciinema' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "asciinema installation complete"
}

main "$@"
