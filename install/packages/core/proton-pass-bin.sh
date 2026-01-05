#!/usr/bin/env bash
# PACKAGE: proton-pass-bin
# DESCRIPTION: Proton Pass password manager
# CATEGORY: core
# UBUNTU_PKG:
# ARCH_PKG: aur:proton-pass-bin
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
    log "Installing proton-pass-bin..."

    # Skip if already installed
    if is_package_installed "proton-pass-bin"; then
        log "proton-pass-bin is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            log "ERROR: proton-pass-bin not in Ubuntu repos, check Proton website"
            return 1
            ;;
        arch)
            install_package "aur:proton-pass-bin"
            ;;
        nixos)
            log "For NixOS, check Proton Pass documentation for installation"
            return 1
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "proton-pass-bin installation complete"
}

main "$@"
