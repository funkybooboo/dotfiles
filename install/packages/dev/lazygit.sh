#!/usr/bin/env bash
# PACKAGE: lazygit
# DESCRIPTION: Simple terminal UI for git commands
# CATEGORY: dev
# UBUNTU_PKG: brew:lazygit
# ARCH_PKG: pacman:lazygit
# NIX_PKG: nixpkgs.lazygit
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing lazygit..."

    case "$DISTRO" in
        ubuntu)
            # On Ubuntu, lazygit not in apt, use Homebrew
            if ! command -v brew &>/dev/null; then
                log "ERROR: Homebrew is required for lazygit on Ubuntu"
                log "Please run package-managers installer first"
                return 1
            fi

            if command -v lazygit &>/dev/null; then
                log "lazygit is already installed"
                return 0
            fi

            install_package "brew:lazygit"
            ;;
        arch)
            # On Arch, prefer pacman over Homebrew
            if is_package_installed "lazygit"; then
                log "lazygit is already installed"
                return 0
            fi

            install_package "pacman:lazygit"
            ;;
        nixos)
            log "For NixOS, add 'lazygit' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "lazygit installation complete"
}

main "$@"
