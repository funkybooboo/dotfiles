#!/usr/bin/env bash
set -e

# --- Step 2: Create the 2FA Secrets File ---
echo "Creating the 2FA secrets file..."

# Prompt for the TOTP secret
read -p "Enter your TOTP secret for Proton (e.g., 'proton=SECRET'): " totp_secret

# Create the .2fa_secrets file
echo "proton=$totp_secret" >~/.2fa_secrets
chmod 600 ~/.2fa_secrets

# --- Step 1: Run only steps 3-6 inside the nix-shell ---
echo "Ensuring git, jq, and stow are available for steps 3-6..."

# Run only steps 3-6 inside a nix-shell with git, jq, and stow installed
nix-shell -p git jq stow --run '

# --- Step 3: Clone the Dotfiles Repository ---
echo "Cloning your dotfiles repository..."

git clone git@github.com:funkybooboo/dotfiles.git ~/dotfiles
cd ~/dotfiles

# --- Step 4: Install the System Configuration ---
echo "Installing NixOS system configuration..."

sudo mkdir -p /etc/nixos
sudo cp etc/nixos/configuration.nix /etc/nixos/configuration.nix

# --- Step 5: Make setup.sh Executable ---
echo "Making setup.sh executable..."

chmod +x setup.sh

# --- Step 6: Apply the Dotfiles Setup ---
echo "Applying the dotfiles setup..."

./setup.sh
'

# --- Step 7: Rebuild NixOS System ---
echo "Rebuilding the NixOS system..."

sudo nixos-rebuild switch

# --- Step 8: Set Up Proton Drive Sync (Optional) ---
read -p "Do you want to set up Proton Drive sync with rclone? (y/N): " setup_sync
if [[ "$setup_sync" == "y" || "$setup_sync" == "Y" ]]; then
    echo "Setting up Proton Drive sync..."

    # Start rclone config
    rclone config

    # Sync documents
    syncDocuments
fi

# Final message before reboot prompt
echo "Installation complete! Please verify everything is set up correctly."

# --- Step 9: Optionally Reboot the System ---
read -p "Would you like to reboot the system now? (y/N): " reboot_system
if [[ "$reboot_system" == "y" || "$reboot_system" == "Y" ]]; then
    echo "Rebooting the system..."
    sudo reboot
fi
