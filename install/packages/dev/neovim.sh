#!/usr/bin/env bash
# PACKAGE: neovim
# DESCRIPTION: Hyperextensible Vim-based text editor
# CATEGORY: dev
# UBUNTU_PKG: pacstall:neovim
# ARCH_PKG: pacman:neovim
# NIX_PKG: nixpkgs.neovim
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing Neovim..."

    case "$DISTRO" in
        ubuntu)
            # On Ubuntu, use Pacstall for latest version
            if ! command -v pacstall &>/dev/null; then
                log "ERROR: Pacstall is required for Neovim on Ubuntu"
                log "Please run package-managers installer first"
                return 1
            fi

            if is_package_installed "neovim"; then
                log "Neovim is already installed"
                return 0
            fi

            install_package "pacstall:neovim"
            ;;
        arch)
            # On Arch, official repos have latest version
            if is_package_installed "neovim"; then
                log "Neovim is already installed"
                return 0
            fi

            install_package "pacman:neovim"
            ;;
        nixos)
            log "For NixOS, add 'neovim' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "Neovim installation complete"
}

main "$@"
