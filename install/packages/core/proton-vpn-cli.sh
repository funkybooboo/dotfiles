#!/usr/bin/env bash
# PACKAGE: proton-vpn-cli
# DESCRIPTION: Proton VPN command-line interface
# CATEGORY: core
# UBUNTU_PKG:
# ARCH_PKG: aur:proton-vpn-cli
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
    log "Installing proton-vpn-cli..."

    # Skip if already installed
    if is_package_installed "proton-vpn-cli"; then
        log "proton-vpn-cli is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            log "ERROR: proton-vpn-cli not in Ubuntu repos, check Proton website"
            return 1
            ;;
        arch)
            install_package "aur:proton-vpn-cli"
            ;;
        nixos)
            log "For NixOS, check Proton VPN documentation for installation"
            return 1
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "proton-vpn-cli installation complete"
}

main "$@"
