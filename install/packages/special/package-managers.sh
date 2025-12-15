#!/usr/bin/env bash
# PACKAGE: package-managers
# DESCRIPTION: Install required package managers for the system
# CATEGORY: special
# UBUNTU_PKG: snapd, flatpak, nix, pacstall, homebrew, rust, go
# ARCH_PKG: yay, flatpak, rust, go
# NIX_PKG: N/A (built-in)
# DEPENDS:
# REBOOT: false
# PRIORITY: 1

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/log.sh"
source "$LIB_DIR/distro.sh"

install_ubuntu_package_managers() {
    log "Installing package managers for Ubuntu..."

    # Snap
    if ! command -v snap &>/dev/null; then
        log "Installing snapd..."
        sudo apt update
        sudo apt install -y snapd
        sudo systemctl enable --now snapd.socket || true
        # Wait for snapd to be ready
        sudo snap wait system seed.loaded || true
    else
        log "snapd already installed"
    fi

    # Flatpak
    if ! command -v flatpak &>/dev/null; then
        log "Installing flatpak..."
        sudo apt install -y flatpak
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    else
        log "flatpak already installed"
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || true
    fi

    # Nix
    if ! command -v nix-env &>/dev/null; then
        log "Installing Nix package manager..."
        sh <(curl -L https://nixos.org/nix/install) --daemon || {
            log "WARNING: Nix installation failed"
        }
    else
        log "Nix already installed"
    fi

    # Pacstall (for latest versions of packages)
    if ! command -v pacstall &>/dev/null; then
        log "Installing Pacstall..."
        sudo bash -c "$(curl -fsSL https://pacstall.dev/q/install)" || {
            log "WARNING: Pacstall installation failed"
        }
    else
        log "Pacstall already installed"
    fi

    # Homebrew
    if ! command -v brew &>/dev/null; then
        log "Installing Homebrew..."
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
            log "WARNING: Homebrew installation failed"
        }
        # Add brew to PATH
        if [ -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        fi
    else
        log "Homebrew already installed"
    fi

    # Rust/Cargo
    if ! command -v cargo &>/dev/null; then
        log "Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y || {
            log "WARNING: Rust installation failed"
        }
        # Source cargo env
        if [ -f "$HOME/.cargo/env" ]; then
            source "$HOME/.cargo/env"
        fi
    else
        log "Rust already installed"
    fi

    # Go
    if ! command -v go &>/dev/null; then
        log "Installing Go..."
        sudo apt install -y golang || {
            log "WARNING: Go installation failed"
        }
    else
        log "Go already installed"
    fi

    log "Ubuntu package managers installation complete"
}

install_arch_package_managers() {
    log "Installing package managers for Arch..."

    # Yay (AUR helper) - must be installed from source
    if ! command -v yay &>/dev/null; then
        log "Installing yay (AUR helper)..."

        # Install build dependencies
        sudo pacman -S --needed --noconfirm git base-devel || {
            log "ERROR: Failed to install yay dependencies"
            return 1
        }

        # Clone and build yay
        local TMP_DIR=$(mktemp -d)
        cd "$TMP_DIR"
        git clone https://aur.archlinux.org/yay.git || {
            log "ERROR: Failed to clone yay repository"
            cd -
            rm -rf "$TMP_DIR"
            return 1
        }
        cd yay
        makepkg -si --noconfirm || {
            log "ERROR: Failed to build yay"
            cd -
            rm -rf "$TMP_DIR"
            return 1
        }
        cd -
        rm -rf "$TMP_DIR"

        log "yay installed successfully"
    else
        log "yay already installed"
    fi

    # Flatpak
    if ! command -v flatpak &>/dev/null; then
        log "Installing flatpak..."
        sudo pacman -S --noconfirm flatpak || {
            log "WARNING: Flatpak installation failed"
        }
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    else
        log "flatpak already installed"
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || true
    fi

    # Rust/Cargo
    if ! command -v cargo &>/dev/null; then
        log "Installing Rust..."
        sudo pacman -S --noconfirm rust || {
            log "WARNING: Rust installation failed"
        }
    else
        log "Rust already installed"
    fi

    # Go
    if ! command -v go &>/dev/null; then
        log "Installing Go..."
        sudo pacman -S --noconfirm go || {
            log "WARNING: Go installation failed"
        }
    else
        log "Go already installed"
    fi

    # Note: Homebrew is generally not needed on Arch
    # Most packages are available via pacman or AUR
    log "Note: Homebrew not needed on Arch (packages available in repos/AUR)"

    log "Arch package managers installation complete"
}

install_nixos_package_managers() {
    log "Installing package managers for NixOS..."

    log "NixOS has Nix built-in."
    log ""
    log "To enable Flatpak, add to configuration.nix:"
    log "  services.flatpak.enable = true;"
    log ""
    log "To install other package managers, add to configuration.nix:"
    log "  environment.systemPackages = with pkgs; [ cargo rustc go ];"
    log ""
    log "Then run: sudo nixos-rebuild switch"

    # If ALLOW_NIX_ENV is set, we could install things imperatively
    # But that goes against NixOS philosophy
    log ""
    log "Note: Imperative package installation with nix-env is available"
    log "      but not recommended on NixOS. Use configuration.nix instead."

    return 0
}

main() {
    log "===== Installing Package Managers ====="

    case "$DISTRO" in
        ubuntu)
            install_ubuntu_package_managers
            ;;
        arch)
            install_arch_package_managers
            ;;
        nixos)
            install_nixos_package_managers
            ;;
        *)
            log "ERROR: Unsupported distribution: $DISTRO"
            return 1
            ;;
    esac

    log "===== Package Managers Installation Complete ====="
}

main "$@"
