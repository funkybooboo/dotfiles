#!/usr/bin/env bash

# Package Manager Abstraction Library
# Provides unified interface for installing packages across distros

# Source dependencies
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/distro.sh"

# Parse package specification: "manager:package" or just "package"
parse_pkg_spec() {
    local spec="$1"
    if [[ "$spec" == *:* ]]; then
        # Has explicit manager
        echo "${spec%%:*}"  # manager
        echo "${spec#*:}"   # package
    else
        # No explicit manager, use default
        echo "default"
        echo "$spec"
    fi
}

# Install package on Ubuntu
install_ubuntu() {
    local manager="$1"
    local pkg="$2"

    case "$manager" in
        apt|default)
            if ! dpkg -s "$pkg" &>/dev/null; then
                log "Installing $pkg via APT..."
                sudo apt install -y "$pkg" || {
                    log "WARNING: Failed to install $pkg via APT"
                    return 1
                }
            else
                log "$pkg already installed (APT)"
            fi
            ;;
        snap)
            if ! snap list 2>/dev/null | grep -q "^$pkg[[:space:]]"; then
                log "Installing $pkg via Snap..."
                sudo snap install "$pkg" || {
                    log "WARNING: Failed to install $pkg via Snap"
                    return 1
                }
            else
                log "$pkg already installed (Snap)"
            fi
            ;;
        snap-classic)
            if ! snap list 2>/dev/null | grep -q "^$pkg[[:space:]]"; then
                log "Installing $pkg via Snap (classic)..."
                sudo snap install "$pkg" --classic || {
                    log "WARNING: Failed to install $pkg via Snap classic"
                    return 1
                }
            else
                log "$pkg already installed (Snap classic)"
            fi
            ;;
        flatpak)
            if ! flatpak list 2>/dev/null | grep -q "$pkg"; then
                log "Installing $pkg via Flatpak..."
                flatpak install -y flathub "$pkg" || {
                    log "WARNING: Failed to install $pkg via Flatpak"
                    return 1
                }
            else
                log "$pkg already installed (Flatpak)"
            fi
            ;;
        pacstall)
            if ! pacstall --list 2>/dev/null | grep -q "^$pkg\$"; then
                log "Installing $pkg via Pacstall..."
                pacstall --install "$pkg" || {
                    log "WARNING: Failed to install $pkg via Pacstall"
                    return 1
                }
            else
                log "$pkg already installed (Pacstall)"
            fi
            ;;
        cargo)
            if ! cargo install --list 2>/dev/null | grep -q "^$pkg "; then
                log "Installing $pkg via Cargo..."
                cargo install "$pkg" || {
                    log "WARNING: Failed to install $pkg via Cargo"
                    return 1
                }
            else
                log "$pkg already installed (Cargo)"
            fi
            ;;
        npm)
            if ! npm list -g --depth=0 2>/dev/null | grep -q "$pkg"; then
                log "Installing $pkg via NPM..."
                npm install -g "$pkg" || {
                    log "WARNING: Failed to install $pkg via NPM"
                    return 1
                }
            else
                log "$pkg already installed (NPM)"
            fi
            ;;
        go)
            log "Installing $pkg via Go..."
            go install "$pkg" || {
                log "WARNING: Failed to install $pkg via Go"
                return 1
            }
            ;;
        brew)
            if ! brew list "$pkg" &>/dev/null; then
                log "Installing $pkg via Homebrew..."
                brew install "$pkg" || {
                    log "WARNING: Failed to install $pkg via Homebrew"
                    return 1
                }
            else
                log "$pkg already installed (Homebrew)"
            fi
            ;;
        nix|nix-env)
            # Extract just the package name if it's nixpkgs.foo format
            local nix_pkg="${pkg#nixpkgs.}"
            if ! nix-env -q 2>/dev/null | grep -qw "$nix_pkg"; then
                log "Installing $pkg via nix-env..."
                nix-env -iA "nixpkgs.$nix_pkg" || {
                    log "WARNING: Failed to install $pkg via nix-env"
                    return 1
                }
            else
                log "$pkg already installed (nix-env)"
            fi
            ;;
        *)
            log "ERROR: Unknown package manager for Ubuntu: $manager"
            return 1
            ;;
    esac
    return 0
}

# Install package on Arch
install_arch() {
    local manager="$1"
    local pkg="$2"

    case "$manager" in
        pacman|default)
            if ! pacman -Q "$pkg" &>/dev/null; then
                log "Installing $pkg via pacman..."
                sudo pacman -S --noconfirm "$pkg" || {
                    log "WARNING: Failed to install $pkg via pacman"
                    return 1
                }
            else
                log "$pkg already installed (pacman)"
            fi
            ;;
        yay|aur)
            if ! pacman -Q "$pkg" &>/dev/null; then
                log "Installing $pkg via yay (AUR)..."
                yay -S --noconfirm "$pkg" || {
                    log "WARNING: Failed to install $pkg via yay"
                    return 1
                }
            else
                log "$pkg already installed (AUR)"
            fi
            ;;
        flatpak)
            if ! flatpak list 2>/dev/null | grep -q "$pkg"; then
                log "Installing $pkg via Flatpak..."
                flatpak install -y flathub "$pkg" || {
                    log "WARNING: Failed to install $pkg via Flatpak"
                    return 1
                }
            else
                log "$pkg already installed (Flatpak)"
            fi
            ;;
        cargo)
            if ! cargo install --list 2>/dev/null | grep -q "^$pkg "; then
                log "Installing $pkg via Cargo..."
                cargo install "$pkg" || {
                    log "WARNING: Failed to install $pkg via Cargo"
                    return 1
                }
            else
                log "$pkg already installed (Cargo)"
            fi
            ;;
        npm)
            if ! npm list -g --depth=0 2>/dev/null | grep -q "$pkg"; then
                log "Installing $pkg via NPM..."
                npm install -g "$pkg" || {
                    log "WARNING: Failed to install $pkg via NPM"
                    return 1
                }
            else
                log "$pkg already installed (NPM)"
            fi
            ;;
        go)
            log "Installing $pkg via Go..."
            go install "$pkg" || {
                log "WARNING: Failed to install $pkg via Go"
                return 1
            }
            ;;
        brew)
            if ! brew list "$pkg" &>/dev/null; then
                log "Installing $pkg via Homebrew..."
                brew install "$pkg" || {
                    log "WARNING: Failed to install $pkg via Homebrew"
                    return 1
                }
            else
                log "$pkg already installed (Homebrew)"
            fi
            ;;
        nix|nix-env)
            # Extract just the package name if it's nixpkgs.foo format
            local nix_pkg="${pkg#nixpkgs.}"
            if ! nix-env -q 2>/dev/null | grep -qw "$nix_pkg"; then
                log "Installing $pkg via nix-env..."
                nix-env -iA "nixpkgs.$nix_pkg" || {
                    log "WARNING: Failed to install $pkg via nix-env"
                    return 1
                }
            else
                log "$pkg already installed (nix-env)"
            fi
            ;;
        *)
            log "ERROR: Unknown package manager for Arch: $manager"
            return 1
            ;;
    esac
    return 0
}

# Install package on NixOS (guidance mode)
install_nixos() {
    local manager="$1"
    local pkg="$2"

    # Extract just the package name if it's nixpkgs.foo format
    local nix_pkg="${pkg#nixpkgs.}"

    log "NOTE: On NixOS, packages should be declared in configuration.nix"
    log "To install $nix_pkg, add it to environment.systemPackages:"
    log "  environment.systemPackages = with pkgs; [ $nix_pkg ]; "
    log "Then run: sudo nixos-rebuild switch"

    # Option: Install imperatively with nix-env if ALLOW_NIX_ENV is set
    if [[ "${ALLOW_NIX_ENV:-false}" == "true" ]]; then
        if ! nix-env -q 2>/dev/null | grep -qw "$nix_pkg"; then
            log "Installing $nix_pkg via nix-env (imperative mode)..."
            nix-env -iA "nixpkgs.$nix_pkg" || {
                log "WARNING: Failed to install $nix_pkg via nix-env"
                return 1
            }
        else
            log "$nix_pkg already installed (nix-env)"
        fi
    fi

    return 0
}

# Main install function - routes to correct distro handler
install_package() {
    local pkg_spec="$1"

    # Parse package specification
    local manager package_name
    read -r manager package_name <<< "$(parse_pkg_spec "$pkg_spec")"

    case "$DISTRO" in
        ubuntu)
            install_ubuntu "$manager" "$package_name"
            ;;
        arch)
            install_arch "$manager" "$package_name"
            ;;
        nixos)
            install_nixos "$manager" "$package_name"
            ;;
        *)
            log "ERROR: Unsupported distribution: $DISTRO"
            return 1
            ;;
    esac
}

# Check if package is installed (distro-agnostic)
is_package_installed() {
    local pkg="$1"

    case "$DISTRO" in
        ubuntu)
            # Check apt, snap, flatpak
            dpkg -s "$pkg" &>/dev/null || \
            snap list 2>/dev/null | grep -q "^$pkg[[:space:]]" || \
            flatpak list 2>/dev/null | grep -q "$pkg" || \
            command -v "$pkg" &>/dev/null
            ;;
        arch)
            # Check pacman, flatpak, or command
            pacman -Q "$pkg" &>/dev/null || \
            flatpak list 2>/dev/null | grep -q "$pkg" || \
            command -v "$pkg" &>/dev/null
            ;;
        nixos)
            # Check nix-env or command availability
            nix-env -q 2>/dev/null | grep -qw "$pkg" || \
            command -v "$pkg" &>/dev/null
            ;;
        *)
            return 1
            ;;
    esac
}

# Export functions for use in other scripts
export -f install_package
export -f is_package_installed
export -f install_ubuntu
export -f install_arch
export -f install_nixos
