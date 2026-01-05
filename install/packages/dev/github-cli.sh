#!/usr/bin/env bash
# PACKAGE: github-cli
# DESCRIPTION: GitHub's official command line tool
# CATEGORY: dev
# UBUNTU_PKG: apt:gh
# ARCH_PKG: pacman:github-cli
# NIX_PKG: nixpkgs.gh
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing github-cli..."

    # Skip if already installed
    if is_package_installed "github-cli" || command -v gh &>/dev/null; then
        log "github-cli is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            log "Adding GitHub CLI repository..."
            curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
            sudo apt update
            install_package "apt:gh"
            ;;
        arch)
            install_package "pacman:github-cli"
            ;;
        nixos)
            log "For NixOS, add 'gh' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "github-cli installation complete"
    log "Run 'gh auth login' to authenticate"
}

main "$@"
