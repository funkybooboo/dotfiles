#!/usr/bin/env bash

set -e
set -o pipefail

install_podman_desktop() {
  if command -v flatpak >/dev/null 2>&1; then
    echo "Installing Podman Desktop..."
    # https://podman-desktop.io/docs/installation/linux-install

    # Add flathub remote if not exists
    if ! flatpak remote-list --user 2>/dev/null | grep -q "flathub"; then
        echo "Adding flathub remote..."
        if ! flatpak remote-add --if-not-exists --user flathub https://flathub.org/repo/flathub.flatpakrepo; then
            echo "Error: Failed to add flathub remote"
            return 1
        fi
    else
        echo "flathub remote already exists"
    fi
    # Install Podman Desktop
    if flatpak install -y --user flathub io.podman_desktop.PodmanDesktop; then
        echo "Podman Desktop installed successfully"

        # Verify installation
        if flatpak list --user 2>/dev/null | grep -q "io.podman_desktop.PodmanDesktop"; then
            echo "Installation verified"
        fi
    else
        echo "Error: Failed to install Podman Desktop"
        return 1
    fi
  else
    echo "Error: Flatpak is not installed. Please install Flatpak first."
    return 1
  fi
}

install_lazydocker() {
  if command -v go >/dev/null 2>&1; then
    echo "Installing lazydocker..."
    # https://github.com/jesseduffield/lazydocker
    if go install github.com/jesseduffield/lazydocker@latest; then
        echo "lazydocker installed successfully"

        # Check if ~/go/bin is in PATH
        GO_BIN_PATH="$HOME/go/bin"
        if [[ ":$PATH:" != *":$GO_BIN_PATH:"* ]]; then
            ./append_config.sh 'export PATH="$PATH:$HOME/go/bin"'
        fi
        # Verify installation
        if [[ -f "$GO_BIN_PATH/lazydocker" ]]; then
            echo "Installation verified: $GO_BIN_PATH/lazydocker"
        fi
    else
        echo "Error: Failed to install lazydocker"
        return 1
    fi
  else
    echo "Error: Go is not installed. Please install Go first."
    return 1
  fi
}

echo "Install a Container Runtime UI"
read -rp "(l)azydocker or (p)odman desktop or or (b)oth or (n)one [l]: " container_ui
case $container_ui in
  n|N)
    echo "No Container Runtime UI selected"
    ;;
  p|P)
    install_podman_desktop
    ;;
  l|L)
    install_lazydocker
    ;;
  *)
    install_podman_desktop
    install_lazydocker
    ;;
esac
