#!/usr/bin/env bash
# PACKAGE: mise
# DESCRIPTION: Dev tools, env vars, task runner (successor to asdf/rtx)
# CATEGORY: core
# UBUNTU_PKG:
# ARCH_PKG: pacman:mise
# NIX_PKG: nixpkgs.mise
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing mise..."

    # Skip if already installed
    if is_package_installed "mise"; then
        log "mise is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            log "Installing mise via install script..."
            curl https://mise.run | sh
            ;;
        arch)
            install_package "pacman:mise"
            ;;
        nixos)
            log "For NixOS, add 'mise' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "mise installation complete"
    log "Add to your shell rc: eval \"\$(mise activate bash)\""
}

main "$@"
