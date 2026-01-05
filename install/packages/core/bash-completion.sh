#!/usr/bin/env bash
# PACKAGE: bash-completion
# DESCRIPTION: Programmable completion for bash
# CATEGORY: core
# UBUNTU_PKG: apt:bash-completion
# ARCH_PKG: pacman:bash-completion
# NIX_PKG: nixpkgs.bash-completion
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing bash-completion..."

    # Skip if already installed
    if is_package_installed "bash-completion"; then
        log "bash-completion is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt:bash-completion"
            ;;
        arch)
            install_package "pacman:bash-completion"
            ;;
        nixos)
            log "For NixOS, add 'bash-completion' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "bash-completion installation complete"
}

main "$@"
