#!/usr/bin/env bash
# PACKAGE: python-is-python3
# DESCRIPTION: Package from APT repository
# CATEGORY: core
# UBUNTU_PKG: apt:python-is-python3
# ARCH_PKG: pacman:python-is-python3
# NIX_PKG: nixpkgs.python-is-python3
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing python-is-python3..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "python-is-python3"; then
                log "python-is-python3 is already installed"
                return 0
            fi
            install_package "apt:python-is-python3"
            ;;
        arch)
            if is_package_installed "python-is-python3"; then
                log "python-is-python3 is already installed"
                return 0
            fi
            install_package "pacman:python-is-python3"
            ;;
        nixos)
            log "For NixOS, add 'python-is-python3' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "python-is-python3 installation complete"
}

main "$@"
