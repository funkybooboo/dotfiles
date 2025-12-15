#!/usr/bin/env bash
# Master Installer - Orchestrates all package installations

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_DIR="$(cd "$SCRIPT_DIR/../packages" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/log.sh"

# Check for supported distro
check_supported_distro || exit 1

SEPARATOR="=============================================================="

# Categories to install (in order)
CATEGORIES=(
    "special/package-managers.sh"  # Must be first (PRIORITY: 1)
    "core"
    "dev"
    "desktop"
    "special"
    "fonts"
)

# Track failures
FAILED_PACKAGES=()
SUCCESSFUL_PACKAGES=()

install_package_file() {
    local pkg_file="$1"
    local pkg_name=$(basename "$pkg_file" .sh)

    echo ""
    echo "${SEPARATOR}"
    log "Installing $pkg_name..."
    echo "${SEPARATOR}"

    if bash "$pkg_file"; then
        log "✓ $pkg_name installed successfully"
        SUCCESSFUL_PACKAGES+=("$pkg_name")
        return 0
    else
        log "✗ $pkg_name installation failed"
        FAILED_PACKAGES+=("$pkg_name")
        return 1
    fi
}

main() {
    log "============================================"
    log "Starting dotfiles installation for $DISTRO_NAME"
    log "============================================"
    log "This may take a while..."
    log ""

    # Install package managers first (CRITICAL)
    if [ -f "$PACKAGES_DIR/special/package-managers.sh" ]; then
        log "PRIORITY: Installing package managers first..."
        install_package_file "$PACKAGES_DIR/special/package-managers.sh" || {
            log "ERROR: Failed to install package managers"
            log "Cannot continue without package managers"
            exit 1
        }
    else
        log "ERROR: package-managers.sh not found"
        exit 1
    fi

    # Install packages by category
    for category in "${CATEGORIES[@]}"; do
        if [ "$category" = "special/package-managers.sh" ]; then
            continue  # Already installed
        fi

        if [ -d "$PACKAGES_DIR/$category" ]; then
            log ""
            log "=========================================="
            log "Installing $category packages..."
            log "=========================================="

            # Count files
            local count=$(find "$PACKAGES_DIR/$category" -name "*.sh" -type f 2>/dev/null | wc -l)
            log "Found $count package(s) in $category/"

            for pkg_file in "$PACKAGES_DIR/$category"/*.sh; do
                [ -f "$pkg_file" ] || continue
                install_package_file "$pkg_file" || true  # Continue on failure
            done
        elif [ -f "$PACKAGES_DIR/$category" ]; then
            install_package_file "$PACKAGES_DIR/$category" || true
        else
            log "WARNING: Category $category not found, skipping"
        fi
    done

    # Report results
    echo ""
    echo ""
    log "============================================"
    log "           Installation Summary"
    log "============================================"
    log "Distribution: $DISTRO_NAME"
    log ""

    if [ ${#SUCCESSFUL_PACKAGES[@]} -gt 0 ]; then
        log "✓ Successfully installed: ${#SUCCESSFUL_PACKAGES[@]} package(s)"
    fi

    if [ ${#FAILED_PACKAGES[@]} -eq 0 ]; then
        log ""
        log "✓✓✓ ALL PACKAGES INSTALLED SUCCESSFULLY! ✓✓✓"
    else
        log ""
        log "✗ Failed to install: ${#FAILED_PACKAGES[@]} package(s)"
        log "Failed packages:"
        for pkg in "${FAILED_PACKAGES[@]}"; do
            log "  - $pkg"
        done
        log ""
        log "Note: Some failures may be expected (e.g., optional packages)"
    fi

    # Check if reboot needed
    log ""
    if [ -f "/var/run/reboot-required" ]; then
        log "⚠ REBOOT REQUIRED"
        log "Some system packages require a restart"
        log "Please reboot your system when convenient"
    fi

    log "============================================"
    log "Installation complete!"
    log "============================================"

    if [ ${#FAILED_PACKAGES[@]} -gt 0 ]; then
        exit 1
    fi
}

main "$@"
