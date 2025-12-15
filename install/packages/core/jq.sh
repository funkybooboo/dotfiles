#!/usr/bin/env bash
# PACKAGE: jq
# DESCRIPTION: Package from APT repository
# CATEGORY: core
# UBUNTU_PKG: apt:jq
# ARCH_PKG: pacman:jq
# NIX_PKG: nixpkgs.jq
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing jq..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "jq"; then
                log "jq is already installed"
                return 0
            fi
            install_package "apt:jq"
            ;;
        arch)
            if is_package_installed "jq"; then
                log "jq is already installed"
                return 0
            fi
            install_package "pacman:jq"
            ;;
        nixos)
            log "For NixOS, add 'jq' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "jq installation complete"
}

main "$@"
