#!/usr/bin/env bash

set -e
set -o pipefail

install_vscodium() {
  echo "Installing VSCodium from official repository..."
  # Download and install the GPG key
  if wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | \
     gpg --dearmor | \
     sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg; then
    echo "GPG key added successfully"
  else
    echo "Error: Failed to add GPG key"
    return 1
  fi
  # Add the repository
  if echo 'deb [ signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg ] https://download.vscodium.com/debs vscodium main' | \
     sudo tee /etc/apt/sources.list.d/vscodium.list > /dev/null; then
    echo "Repository added successfully"
  else
    echo "Error: Failed to add repository"
    return 1
  fi
  # Update package list and install
  echo "Updating package lists..."
  if sudo apt update; then
    echo "Installing VSCodium..."
    if sudo apt install -y codium; then
      echo "VSCodium installed successfully"
    else
      echo "Error: Failed to install VSCodium"
      return 1
    fi
  else
    echo "Error: Failed to update package lists"
    return 1
  fi
}

install_vscode() {
  if command -v snap >/dev/null 2>&1; then
    echo "Installing VS Code via snap..."
    sudo snap install --classic code
  else
    echo "Error: snap is not available on this system"
    return 1
  fi
}

echo "Install lightweight code editor"
read -rp "vscod(e) or vscodiu(m) or (b)oth or (n)one [v]: " editor
case $editor in
  e|E)
    install_vscode
    ;;
  m|M)
    install_vscodium
    ;;
  b|B)
    install_vscode
    install_vscodium
    ;;
  *)
    echo "No lightweight code editor will be installed"
    ;;
esac
