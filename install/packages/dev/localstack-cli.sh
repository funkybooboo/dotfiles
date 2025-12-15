#!/usr/bin/env bash
# PACKAGE: localstack-cli
# DESCRIPTION: Package from Homebrew
# CATEGORY: dev
# UBUNTU_PKG: brew:localstack/tap/localstack-cli
# ARCH_PKG: pacman:localstack-cli
# NIX_PKG: nixpkgs.localstack-cli
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing localstack-cli..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "localstack-cli"; then
                log "localstack-cli is already installed"
                return 0
            fi
            install_package "brew:localstack/tap/localstack-cli"
            ;;
        arch)
            if is_package_installed "localstack-cli"; then
                log "localstack-cli is already installed"
                return 0
            fi
            install_package "pacman:localstack-cli"
            ;;
        nixos)
            log "For NixOS, add 'localstack-cli' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "localstack-cli installation complete"
}

main "$@"
