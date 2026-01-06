#!/usr/bin/env bash
# PACKAGE: pacman-contrib
# DESCRIPTION: Contributed scripts and tools for pacman systems
# CATEGORY: core
# UBUNTU_PKG:
# ARCH_PKG: pacman:pacman-contrib
# NIX_PKG:
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing pacman-contrib..."

    # Skip if already installed
    if is_package_installed "pacman-contrib"; then
        log "pacman-contrib is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            log "ERROR: pacman-contrib is Arch-specific (pacman utilities)"
            return 1
            ;;
        arch)
            install_package "pacman:pacman-contrib"
            ;;
        nixos)
            log "ERROR: pacman-contrib is Arch-specific (pacman utilities)"
            return 1
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "pacman-contrib installation complete"
}

main "$@"
