#!/usr/bin/env bash
#
# install-software/os.sh
# Installs common utilities on Rhino Linux or NixOS
#
set -euo pipefail

TS() { date '+%F %T'; }
echo "[$(TS)] Installing software on this system..."

# ===============================
# Package Lists (edit here)
# ===============================

# APT packages (Debian/Ubuntu/Rhino Linux)
# User-installed APT packages
APT_PACKAGES=(
    amberol
    autojump
    axel
    balena-etcher
    bat
    blanket
    blueman
    bubblewrap
    build-essential
    chkrootkit
    chrony
    clamav
    clang
    clisp
    cmake
    cozy
    distrobox
    fdclone
    fish
    flatpak
    fzf
    gh
    git
    git-delta
    git-remote-gcrypt
    gnome-calculator
    gnome-disk-utility
    guvcview
    handbrake
    kitty
    lazydocker
    lazygit
    lua5.1
    luarocks
    lynis
    mate-polkit
    media-types
    mugshot
    nano
    mpv
    mtools
    net-tools
    network-manager-gnome
    ntfs-3g
    oathtool
    openconnect
    pandoc
    pipx
    plocate
    power-profiles-daemon
    python3-poetry
    python3-pygments
    python3-rich
    redshift
    redshift-gtk
    rustup
    sbcl
    spice-vdagent
    steam
    strace
    swig
    synergy
    texlive-latex-base
    thunar
    thunar-volman
    tree
    virt-manager
    wget
    wikiman
    xprintidle
    zoxide
)

# Snap packages
SNAP_PACKAGES=(
    bare
    core
    core20
    core22
    core24
    gnome-42-2204
    gnome-46-2404
    gtk-common-themes
    hello-world
    jump
    libreoffice
    mermaid-cli
    mesa-2404
    multipass
    rclone
    snapd
    tldr
    yazi
)

# Flatpak applications
FLATPAK_PACKAGES=(
    com.github.tchx84.Flatseal
    com.hunterwittenborn.Celeste
    com.jetbrains.CLion
    com.jetbrains.DataGrip
    com.jetbrains.GoLand
    com.jetbrains.IntelliJ-IDEA-Ultimate
    com.jetbrains.PhpStorm
    com.jetbrains.PyCharm-Professional
    com.jetbrains.Rider
    com.jetbrains.RubyMine
    com.jetbrains.RustRover
    com.jetbrains.WebStorm
    com.protonvpn.www
    me.proton.Pass
    org.freedesktop.Platform
    org.freedesktop.Platform.GL.default
    org.freedesktop.Platform.GL.default
    org.freedesktop.Platform.VAAPI.Intel
    org.freedesktop.Platform.VAAPI.Intel
    org.freedesktop.Platform.codecs-extra
    org.freedesktop.Platform.openh264
    org.freedesktop.Sdk
    org.freedesktop.Sdk
    org.freedesktop.Sdk.Compat.i386
    org.gnome.Platform
    org.gnome.Platform
    org.gtk.Gtk3theme.Greybird
    org.gtk.Gtk3theme.adw-gtk3
    org.gtk.Gtk3theme.adw-gtk3-dark
)

# nix-env packages
NIX_PACKAGES=(
    tectonic
    biber
)

# Rust (cargo) packages
CARGO_PACKAGES=(
    fnm
)

# Go packages (full import paths)
GO_PACKAGES=(
    github.com/charmbracelet/glow@latest
)

# Pacstall packages
PACSTALL_PACKAGES=(
    brave-browser
    brave-keyring
    distrobox
    docker
    docker-buildx-plugin
    docker-compose-plugin
    fake-ubuntu-advantage-tools
    firefox
    hello-rhino
    lazydocker
    lazygit
    librewolf
    linux-headers-6.16.1-061601-generic
    linux-headers-6.16.1-061601
    linux-image-unsigned-6.16.1-061601-generic
    linux-kernel-6.16.1
    linux-modules-6.16.1-061601-generic
    nala
    neovim
    nushell
    nutext
    obsidian
    ollama
    otf-firamono-nerd
    otf-opendyslexic-nerd
    protonmail-bridge
    quintom-cursor-theme
    rhino-grub-theme
    rhino-hotfix
    rhino-kvantum-theme
    rhino-neofetch
    rhino-pkg
    rhino-plymouth-theme
    rhino-system
    rhino-ubxi-core
    signal-desktop
    timeshift
    ttf-jetbrains-mono-nerd
    ubxi-kde-desktop
    ulauncher
    codium
    zoom
)

# ===============================
# Installation Logic
# ===============================

# Ensure we are running as root for system packages
if [[ $EUID -ne 0 ]]; then
    echo "[$(TS)] ERROR: Please run this script with sudo"
    exit 1
fi

# Detect distro
if command -v nixos-version >/dev/null 2>&1; then
    DISTRO="NixOS"
elif [ -f /etc/os-release ]; then
    DISTRO_NAME=$(grep '^NAME=' /etc/os-release | cut -d= -f2 | tr -d '"')
    if [[ "$DISTRO_NAME" =~ [Rr]hino ]]; then
        DISTRO="Rhino Linux"
    else
        DISTRO=""
    fi
else
    DISTRO=""
fi

if [ -z "$DISTRO" ]; then
    echo "Unsupported distribution."
    exit 1
fi

echo "Detected: $DISTRO"
echo ""

# 1) System packages
if [ "$DISTRO" = "Rhino Linux" ]; then
    echo "[$(TS)] Updating APT..."
    apt update -y
    apt upgrade -y
elif [ "$DISTRO" = "NixOS" ]; then
    echo "[$(TS)] Updating Nix channels..."
    nix-channel --update
fi
echo ""

echo "[$(TS)] Installing system packages..."
for pkg in "${APT_PACKAGES[@]}"; do
    if ! command -v "$pkg" >/dev/null 2>&1; then
        echo "[$(TS)] Installing $pkg..."
        apt install -y "$pkg" 2>/dev/null || true
    else
        echo "[$(TS)] $pkg already installed."
    fi
done
echo ""

# 2) Flatpak
echo "[$(TS)] Installing Flatpak apps..."
for pkg in "${FLATPAK_PACKAGES[@]}"; do
    if ! flatpak list | grep -q "$pkg"; then
        echo "[$(TS)] Installing $pkg..."
        flatpak install -y "$pkg"
    else
        echo "[$(TS)] $pkg already installed."
    fi
done
echo ""

# 3) Snap
echo "[$(TS)] Installing Snap packages..."
for pkg in "${SNAP_PACKAGES[@]}"; do
    if ! snap list | grep -q "^$pkg "; then
        echo "[$(TS)] Installing $pkg..."
        snap install "$pkg"
    else
        echo "[$(TS)] $pkg already installed."
    fi
done
echo ""

# 4) nix-env
if command -v nix-env >/dev/null 2>&1; then
    echo "[$(TS)] Installing nix-env packages..."
    for pkg in "${NIX_PACKAGES[@]}"; do
        if ! nix-env -q | grep -q "^$pkg"; then
            echo "[$(TS)] Installing $pkg via nix-env..."
            nix-env -iA nixpkgs."$pkg"
        else
            echo "[$(TS)] $pkg already installed (nix-env)."
        fi
    done
fi
echo ""

# 5) Rust (cargo)
if command -v cargo >/dev/null 2>&1; then
    echo "[$(TS)] Installing Rust (cargo) packages..."
    for pkg in "${CARGO_PACKAGES[@]}"; do
        if ! cargo install --list | grep -q "^$pkg "; then
            echo "[$(TS)] Installing $pkg..."
            cargo install "$pkg"
        else
            echo "[$(TS)] $pkg already installed (cargo)."
        fi
    done
fi
echo ""

# 6) Go packages
if command -v go >/dev/null 2>&1; then
    echo "[$(TS)] Installing Go packages..."
    for pkg in "${GO_PACKAGES[@]}"; do
        go install "$pkg" || true
        echo "[$(TS)] Installed $pkg"
    done
fi
echo ""

# 7) Pacstall packages
if command -v pacstall >/dev/null 2>&1; then
    echo "[$(TS)] Installing Pacstall packages..."
    for pkg in "${PACSTALL_PACKAGES[@]}"; do
        if ! pacstall --list | grep -q "^~ $pkg"; then
            echo "[$(TS)] Installing $pkg via Pacstall..."
            pacstall --install "$pkg" --yes || true
        else
            echo "[$(TS)] $pkg already installed (Pacstall)."
        fi
    done
else
    echo "[$(TS)] Pacstall not installed, skipping Pacstall packages."
fi
echo ""

echo "[$(TS)] Software installation complete"
