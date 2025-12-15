#!/usr/bin/env bash
# Pre-Reboot Installer - System-level packages that may require reboot

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_DIR="$(cd "$SCRIPT_DIR/../packages" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/log.sh"

check_supported_distro || exit 1

SEPARATOR="=============================================================="

# Pre-reboot packages (system-level, may require reboot)
PRE_REBOOT_PACKAGES=(
    "special/package-managers.sh"    # Must be first
    "special/basic-system.sh"         # Basic system packages (if exists)
    "special/cuda.sh"                 # CUDA/NVIDIA drivers (if exists)
    "special/container-runtime.sh"    # Docker/Podman (if exists)
)

FAILED_PACKAGES=()

install_package_file() {
    local pkg_file="$1"
    local pkg_name=$(basename "$pkg_file" .sh)

    if [ ! -f "$pkg_file" ]; then
        log "Package $pkg_name not found, skipping"
        return 0
    fi

    echo ""
    echo "${SEPARATOR}"
    log "Installing $pkg_name..."
    echo "${SEPARATOR}"

    if bash "$pkg_file"; then
        log "✓ $pkg_name installed successfully"
        return 0
    else
        log "✗ $pkg_name installation failed"
        FAILED_PACKAGES+=("$pkg_name")
        return 1
    fi
}

main() {
    log "============================================"
    log "Pre-Reboot Installation ($DISTRO_NAME)"
    log "============================================"
    log "Installing system-level packages..."
    log ""

    for pkg in "${PRE_REBOOT_PACKAGES[@]}"; do
        install_package_file "$PACKAGES_DIR/$pkg" || true
    done

    log ""
    log "============================================"
    log "Pre-Reboot Installation Complete"
    log "============================================"

    if [ ${#FAILED_PACKAGES[@]} -gt 0 ]; then
        log "✗ Some packages failed to install:"
        for pkg in "${FAILED_PACKAGES[@]}"; do
            log "  - $pkg"
        done
    else
        log "✓ All pre-reboot packages installed successfully"
    fi

    log ""
    log "⚠ REBOOT RECOMMENDED"
    log "System-level packages have been installed."
    log "Please reboot before running post-reboot.sh"
    log ""

    read -p "Reboot now? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log "Rebooting..."
        sudo reboot
    else
        log "Please reboot manually before continuing"
    fi
}

main "$@"
