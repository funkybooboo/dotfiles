#!/usr/bin/env bash
# PACKAGE: task
# DESCRIPTION: Feature-rich command-line task management tool
# CATEGORY: core
# UBUNTU_PKG: apt:taskwarrior
# ARCH_PKG: pacman:task
# NIX_PKG: nixpkgs.taskwarrior
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing task..."

    # Skip if already installed
    if is_package_installed "task" || is_package_installed "taskwarrior"; then
        log "task is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            install_package "apt:taskwarrior"
            ;;
        arch)
            install_package "pacman:task"
            ;;
        nixos)
            log "For NixOS, add 'taskwarrior' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "task installation complete"
}

main "$@"
