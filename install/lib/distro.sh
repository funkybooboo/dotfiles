#!/usr/bin/env bash

# Distro Detection Library
# Detects Linux distribution and provides helper functions

# Detect the current Linux distribution
detect_distro() {
    # Check for NixOS first (most specific)
    if command -v nixos-version >/dev/null 2>&1; then
        echo "nixos"
        return 0
    fi

    # Check /etc/os-release for other distros
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            ubuntu|debian)
                echo "ubuntu"
                return 0
                ;;
            arch|manjaro|endeavouros)
                echo "arch"
                return 0
                ;;
            nixos)
                echo "nixos"
                return 0
                ;;
            *)
                echo "unknown"
                return 1
                ;;
        esac
    fi

    # Fallback: unknown
    echo "unknown"
    return 1
}

# Get distro display name
get_distro_name() {
    if command -v nixos-version >/dev/null 2>&1; then
        echo "NixOS $(nixos-version 2>/dev/null || echo 'Unknown Version')"
        return 0
    fi

    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$NAME"
        return 0
    fi

    echo "Unknown Linux"
    return 1
}

# Export for use in other scripts
export DISTRO=$(detect_distro)
export DISTRO_NAME=$(get_distro_name)

# Helper functions to check if running on specific distro
is_nixos() {
    [ "$DISTRO" = "nixos" ]
}

is_ubuntu() {
    [ "$DISTRO" = "ubuntu" ]
}

is_arch() {
    [ "$DISTRO" = "arch" ]
}

# Validate supported distro
check_supported_distro() {
    if ! is_nixos && ! is_ubuntu && ! is_arch; then
        if command -v log >/dev/null 2>&1; then
            log "ERROR: Unsupported distribution: $DISTRO"
            log "Supported distributions: NixOS, Ubuntu/Debian, Arch Linux"
        else
            echo "ERROR: Unsupported distribution: $DISTRO" >&2
            echo "Supported distributions: NixOS, Ubuntu/Debian, Arch Linux" >&2
        fi
        return 1
    fi

    if command -v log >/dev/null 2>&1; then
        log "Detected distribution: $DISTRO_NAME"
    else
        echo "Detected distribution: $DISTRO_NAME"
    fi
    return 0
}

# Export functions for use in other scripts
export -f is_nixos
export -f is_ubuntu
export -f is_arch
export -f check_supported_distro
