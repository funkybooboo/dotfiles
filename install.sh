#!/usr/bin/env bash
# Simple Arch Linux Package Installer

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}Arch Linux Package Installation${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

# Check if running on Arch Linux
if [ -f /etc/os-release ]; then
  . /etc/os-release
  case "$ID" in
  arch | manjaro | endeavouros)
    echo -e "${GREEN}✓${NC} Detected: $NAME"
    ;;
  *)
    echo -e "${RED}✗${NC} This script only supports Arch Linux"
    exit 1
    ;;
  esac
else
  echo -e "${RED}✗${NC} Cannot detect distribution"
  exit 1
fi

echo ""

# Update system first
echo -e "${BLUE}>>> Updating system packages...${NC}"
sudo pacman -Syu --noconfirm
echo ""

# Install yay if not present
if ! command -v yay &>/dev/null; then
  echo -e "${BLUE}>>> Installing yay (AUR helper)...${NC}"
  sudo pacman -S --needed --noconfirm git base-devel
  TMP_DIR=$(mktemp -d)
  git clone https://aur.archlinux.org/yay.git "$TMP_DIR/yay"
  (cd "$TMP_DIR/yay" && makepkg -si --noconfirm)
  rm -rf "$TMP_DIR"
  echo -e "${GREEN}✓${NC} yay installed"
  echo ""
else
  echo -e "${GREEN}✓${NC} yay already installed"
  echo ""
fi

# Core system packages
echo -e "${BLUE}>>> Installing core packages...${NC}"
sudo pacman -S --needed --noconfirm \
  git \
  curl \
  wget \
  base-devel \
  linux-headers
echo ""

# Shell & Terminal utilities
echo -e "${BLUE}>>> Installing shell utilities...${NC}"
sudo pacman -S --needed --noconfirm \
  fish \
  fzf \
  ripgrep \
  fd \
  bat \
  eza \
  dust \
  btop \
  fastfetch \
  jq \
  wl-clipboard
echo ""

# Development tools
echo -e "${BLUE}>>> Installing development tools...${NC}"
sudo pacman -S --needed --noconfirm \
  neovim \
  docker \
  docker-compose \
  github-cli

yay -S --needed --noconfirm \
  lazygit \
  lazydocker \
  act
echo ""

# Flatpak
echo -e "${BLUE}>>> Installing flatpak...${NC}"
sudo pacman -S --needed --noconfirm flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
echo ""

# Desktop applications
echo -e "${BLUE}>>> Installing desktop applications...${NC}"
yay -S --needed --noconfirm librewolf-bin
echo ""

# System utilities
echo -e "${BLUE}>>> Installing system utilities...${NC}"
sudo pacman -S --needed --noconfirm \
  power-profiles-daemon \
  fwupd \
  openssh \
  wireguard-tools \
  openresolv \
  rsync
echo ""

# Enable services
echo -e "${BLUE}>>> Enabling services...${NC}"
sudo systemctl enable docker.service
sudo systemctl start docker.service
sudo usermod -aG docker "$USER"
echo -e "${GREEN}✓${NC} Docker enabled"

sudo systemctl enable power-profiles-daemon.service
sudo systemctl start power-profiles-daemon.service
echo -e "${GREEN}✓${NC} Power profiles daemon enabled"
echo ""

echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}Installation Complete!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "${YELLOW}⚠${NC} Please log out and back in for group changes to take effect"
echo ""
