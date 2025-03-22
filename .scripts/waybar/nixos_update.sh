#!/usr/bin/env bash

# Function to handle system update
update_system() {
    # Run the system update without password prompt (sudoers should allow it)
    sudo nixos-rebuild switch --upgrade
}

# Check if the update action was triggered
if [ "$1" == "update" ]; then
    update_system
    exit 0
fi

# Check if there are outdated packages
outdated_packages=$(nix-env -u --dry-run | grep -i "would upgrade")

# Output concise status
if [ -z "$outdated_packages" ]; then
    echo "Up to date"
else
    echo "Updates"
fi
