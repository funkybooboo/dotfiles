#!/usr/bin/env bash

set -e
set -o pipefail

# Install basic tools
echo "Installing basic tools..."
PACKAGES=(
    git
    curl
    vim
    tldr
    wget
    apt-transport-https
    gpg
    libfuse2
    golang
    flatpak
    nodejs
    npm
    jq
    ca-certificates
)
if ! sudo apt -y install "${PACKAGES[@]}"; then
    echo "Error: Failed to install some packages"
    exit 1
fi
# Add Flathub repository
echo "Adding Flathub repository..."
if ! sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo; then
    echo "Warning: Failed to add Flathub repository"
fi
# Add go binaries to path
./append_config.sh "export PATH=\$PATH:\${HOME}/go/bin"

echo "Basic tools installation completed successfully!"
