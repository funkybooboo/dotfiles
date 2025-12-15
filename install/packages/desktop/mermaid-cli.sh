#!/usr/bin/env bash
# PACKAGE: mermaid-cli
# DESCRIPTION: Package from Snap store
# CATEGORY: desktop
# UBUNTU_PKG: snap:mermaid-cli
# ARCH_PKG: pacman:mermaid-cli
# NIX_PKG: nixpkgs.mermaid-cli
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing mermaid-cli..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "mermaid-cli"; then
                log "mermaid-cli is already installed"
                return 0
            fi
            install_package "snap:mermaid-cli"
            ;;
        arch)
            if is_package_installed "mermaid-cli"; then
                log "mermaid-cli is already installed"
                return 0
            fi
            install_package "pacman:mermaid-cli"
            ;;
        nixos)
            log "For NixOS, add 'mermaid-cli' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "mermaid-cli installation complete"
}

main "$@"
