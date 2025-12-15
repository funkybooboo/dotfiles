#!/usr/bin/env bash
# PACKAGE: basic-system
# DESCRIPTION: Basic system development tools and libraries
# CATEGORY: special
# UBUNTU_PKG: build-essential and dependencies
# ARCH_PKG: base-devel
# NIX_PKG: N/A (handled in configuration.nix)
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../../lib" && pwd)"

source "$LIB_DIR/distro.sh"
source "$LIB_DIR/log.sh"

install_ubuntu_basic() {
    log "Installing basic system tools for Ubuntu..."

    sudo apt update
    sudo apt install -y \
        software-properties-common \
        curl \
        wget \
        git \
        sudo \
        ca-certificates \
        gnupg \
        lsb-release \
        apt-transport-https \
        build-essential \
        zlib1g-dev \
        libncurses5-dev \
        libgdbm-dev \
        libnss3-dev \
        libssl-dev \
        libreadline-dev \
        libffi-dev \
        libsqlite3-dev \
        libbz2-dev

    log "Ubuntu basic system tools installed"
}

install_arch_basic() {
    log "Installing basic system tools for Arch..."

    sudo pacman -Syu --noconfirm
    sudo pacman -S --needed --noconfirm \
        base-devel \
        git \
        wget \
        curl \
        sudo \
        ca-certificates \
        gnupg \
        openssl \
        readline \
        sqlite \
        zlib \
        ncurses \
        gdbm \
        libffi \
        bzip2

    log "Arch basic system tools installed"
}

main() {
    log "===== Installing Basic System Tools ====="

    case "$DISTRO" in
        ubuntu)
            install_ubuntu_basic
            ;;
        arch)
            install_arch_basic
            ;;
        nixos)
            log "For NixOS, ensure these are in configuration.nix:"
            log "  environment.systemPackages = with pkgs; ["
            log "    git wget curl gnupg"
            log "    gcc gnumake"
            log "    zlib ncurses readline sqlite openssl"
            log "  ];"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "===== Basic System Tools Installation Complete ====="
}

main "$@"
