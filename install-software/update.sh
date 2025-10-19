#!/usr/bin/env bash

set -e
set -o pipefail

echo "Update and install basic tools"
# Update package lists and upgrade system
echo "Updating package lists..."
if ! sudo apt update; then
    echo "Error: Failed to update package lists"
    exit 1
fi
echo "Upgrading system packages..."
if ! sudo apt -y upgrade; then
    echo "Error: Failed to upgrade packages"
    exit 1
fi
