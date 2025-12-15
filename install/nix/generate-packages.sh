#!/usr/bin/env bash
# NixOS Package List Generator
# Parses all package installers and generates a NixOS configuration

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_DIR="$(cd "$SCRIPT_DIR/../packages" && pwd)"
OUTPUT_FILE="$SCRIPT_DIR/generated-packages.nix"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
}

main() {
    log "Generating NixOS package list..."
    log "Scanning: $PACKAGES_DIR"

    # Array to store package names
    declare -a packages=()

    # Find all package installer files
    while IFS= read -r -d '' installer; do
        # Extract NIX_PKG metadata
        nix_pkg=$(grep "^# NIX_PKG:" "$installer" | cut -d: -f2- | xargs || true)

        if [ -n "$nix_pkg" ] && [ "$nix_pkg" != "N/A" ] && [[ ! "$nix_pkg" =~ ^N/A ]]; then
            # Remove nixpkgs. prefix if present
            pkg_name="${nix_pkg#nixpkgs.}"

            # Skip if empty or still contains N/A
            if [ -n "$pkg_name" ] && [[ ! "$pkg_name" =~ N/A ]]; then
                packages+=("$pkg_name")
            fi
        fi
    done < <(find "$PACKAGES_DIR" -name "*.sh" -type f -print0)

    # Sort packages
    IFS=$'\n' sorted_packages=($(sort <<<"${packages[*]}" | uniq))
    unset IFS

    log "Found ${#sorted_packages[@]} NixOS packages"

    # Generate Nix configuration
    cat > "$OUTPUT_FILE" <<'NIXEOF'
# Auto-generated NixOS package list
# Generated from dotfiles package installers
#
# Usage:
#   1. Copy this file to your NixOS configuration directory
#   2. Import in configuration.nix:
#        imports = [ ./generated-packages.nix ];
#   3. Run: sudo nixos-rebuild switch
#
# Or copy the package list directly into your configuration.nix

{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
NIXEOF

    # Add packages
    for pkg in "${sorted_packages[@]}"; do
        echo "    $pkg" >> "$OUTPUT_FILE"
    done

    # Close the Nix expression
    cat >> "$OUTPUT_FILE" <<'NIXEOF'
  ];
}
NIXEOF

    log "Generated: $OUTPUT_FILE"
    log ""
    log "Package list:"
    log "============="
    for pkg in "${sorted_packages[@]}"; do
        log "  - $pkg"
    done
    log "============="
    log "Total: ${#sorted_packages[@]} packages"
    log ""
    log "To use this on NixOS:"
    log "  1. Copy to /etc/nixos/:"
    log "     sudo cp $OUTPUT_FILE /etc/nixos/"
    log "  2. Import in configuration.nix:"
    log "     imports = [ ./generated-packages.nix ];"
    log "  3. Rebuild:"
    log "     sudo nixos-rebuild switch"
}

main "$@"
