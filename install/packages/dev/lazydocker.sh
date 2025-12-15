#!/usr/bin/env bash
# PACKAGE: lazydocker
# DESCRIPTION: Package from Homebrew
# CATEGORY: dev
# UBUNTU_PKG: brew:lazydocker
# ARCH_PKG: yay:lazydocker
# NIX_PKG: nixpkgs.lazydocker
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing lazydocker..."

    case "$DISTRO" in
        ubuntu)
            if is_package_installed "lazydocker"; then
                log "lazydocker is already installed"
                return 0
            fi
            install_package "brew:lazydocker"
            ;;
        arch)
            if is_package_installed "lazydocker"; then
                log "lazydocker is already installed"
                return 0
            fi
            install_package "yay:lazydocker"
            ;;
        nixos)
            log "For NixOS, add 'lazydocker' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "lazydocker installation complete"
}

main "$@"
