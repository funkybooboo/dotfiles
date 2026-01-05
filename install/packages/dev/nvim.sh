#!/usr/bin/env bash
# Install Neovim

if command -v nvim &> /dev/null; then
  echo "nvim is already installed"
  exit 0
fi

if command -v pacman &> /dev/null; then
  sudo pacman -S --noconfirm neovim
elif command -v apt-get &> /dev/null; then
  sudo apt-get install -y neovim
elif command -v nix-env &> /dev/null; then
  nix-env -iA nixpkgs.neovim
else
  echo "Unsupported package manager"
  exit 1
fi

echo "nvim installed successfully"
