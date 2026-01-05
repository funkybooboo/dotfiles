#!/usr/bin/env bash
# PACKAGE: ttf-jetbrains-mono-nerd
# DESCRIPTION: JetBrains Mono Nerd Font
# CATEGORY: fonts
# UBUNTU_PKG:
# ARCH_PKG: aur:ttf-jetbrains-mono-nerd
# NIX_PKG: nixpkgs.nerdfonts
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing ttf-jetbrains-mono-nerd..."

    # Skip if already installed
    if is_package_installed "ttf-jetbrains-mono-nerd"; then
        log "ttf-jetbrains-mono-nerd is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            log "Installing from Nerd Fonts..."
            cd /tmp
            wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
            unzip -o JetBrainsMono.zip -d ~/.local/share/fonts/
            fc-cache -f
            rm JetBrainsMono.zip
            ;;
        arch)
            install_package "aur:ttf-jetbrains-mono-nerd"
            ;;
        nixos)
            log "For NixOS, add to fonts.packages in configuration.nix:"
            log "  (nerdfonts.override { fonts = [ \"JetBrainsMono\" ]; })"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "ttf-jetbrains-mono-nerd installation complete"
}

main "$@"
