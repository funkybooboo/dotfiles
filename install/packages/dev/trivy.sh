#!/usr/bin/env bash
# PACKAGE: trivy
# DESCRIPTION: Package from Homebrew
# CATEGORY: dev
# UBUNTU_PKG: brew:trivy
# ARCH_PKG: pacman:trivy
# NIX_PKG: nixpkgs.trivy
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing trivy..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "trivy"; then
                log "trivy is already installed"
                return 0
            fi
            install_package "brew:trivy"
            ;;
        arch)
            if is_package_installed "trivy"; then
                log "trivy is already installed"
                return 0
            fi
            install_package "pacman:trivy"
            ;;
        nixos)
            log "For NixOS, add 'trivy' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "trivy installation complete"
}

main "$@"
