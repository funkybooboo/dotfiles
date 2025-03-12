#!/usr/bin/env bash

set -e # Exit on error

echo "🔍 Checking for NixOS updates..."

# Fetch the latest channel updates without applying them
echo "📡 Updating Nix channels..."
sudo nix-channel --update >/dev/null

# Get the current system version
CURRENT_VERSION=$(nixos-version)
echo "🖥️ Current NixOS version: $CURRENT_VERSION"

# Check if there are updates available
AVAILABLE_UPDATES=$(nix-env -qa --available --outdated 2>/dev/null)

if [[ -n "$AVAILABLE_UPDATES" ]]; then
    echo "🚀 Updates available!"
    echo "$AVAILABLE_UPDATES"
else
    echo "✅ Your system is up-to-date!"
fi
