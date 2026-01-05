#!/usr/bin/env bash
# PACKAGE: yay
# DESCRIPTION: AUR helper written in Go
# CATEGORY: core
# UBUNTU_PKG:
# ARCH_PKG: aur:yay
# NIX_PKG:
# DEPENDS: base-devel git
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/package-manager.sh"
source "$LIB_DIR/log.sh"

main() {
    log "Installing yay..."

    # Skip if already installed
    if is_package_installed "yay" || command -v yay &>/dev/null; then
        log "yay is already installed"
        return 0
    fi

    # Install based on distro
    case "$DISTRO" in
        ubuntu)
            log "ERROR: yay is Arch-specific (AUR helper)"
            return 1
            ;;
        arch)
            log "Building yay from AUR..."
            cd /tmp
            git clone https://aur.archlinux.org/yay.git
            cd yay
            makepkg -si --noconfirm
            cd ..
            rm -rf yay
            ;;
        nixos)
            log "ERROR: yay is Arch-specific (AUR helper)"
            return 1
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "yay installation complete"
}

main "$@"
