#!/usr/bin/env bash

set -e # Exit on error

echo "🔄 Updating NixOS..."

# Step 1: Update Nix channels
echo "📡 Updating Nix channels..."
sudo nix-channel --update

# Step 2: Upgrade the system
echo "⚙️ Rebuilding NixOS..."
sudo nixos-rebuild switch --upgrade

# Step 3: Clean up old generations
echo "🧹 Cleaning up old packages..."
sudo nix-collect-garbage -d

# Step 4: Show current version
echo "✅ NixOS version after update:"
nixos-version

# Ask if user wants to reboot
read -p "🔁 Do you want to reboot now? (y/N) " REBOOT
if [[ "$REBOOT" =~ ^[Yy]$ ]]; then
    echo "🚀 Rebooting..."
    sudo reboot
else
    echo "✅ Update complete. No reboot required."
fi
