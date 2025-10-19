#!/usr/bin/env bash

set -e
set -o pipefail

install_docker() {
  # https://docs.docker.com/engine/install/ubuntu/
  # https://docs.docker.com/engine/install/linux-postinstall/
  echo "installing Docker..."

  # Check if Docker is already installed and running
  if command -v docker &> /dev/null && docker --version &> /dev/null; then
      echo "Docker is already installed: $(docker --version)"

      # Check if Docker service is running
      if systemctl is-active --quiet docker; then
          echo "Docker service is already running"
      else
          echo "Starting Docker service..."
          sudo systemctl start docker
      fi

      # Check if current user is in docker group
      if groups "${USER}" | grep -q docker; then
          echo "User $USER is already in docker group"
          echo "Docker installation is complete and up to date"
          return 0
      else
          echo "Adding user $USER to docker group..."
          sudo usermod -aG docker "${USER}"
          echo "Please log out and back in for group changes to take effect"
          return 0
      fi
  fi

  echo "Docker not found or not working properly. Installing..."

  # Update package index
  sudo apt-get update

  # Install prerequisites if not already installed
  PREREQS="ca-certificates curl"
  for pkg in $PREREQS; do
      if ! dpkg -l | grep -q "^ii  $pkg "; then
          echo "Installing $pkg..."
          sudo apt-get install -y "$pkg"
      else
          echo "$pkg is already installed"
      fi
  done

  # Create keyrings directory if it doesn't exist
  if [ ! -d /etc/apt/keyrings ]; then
      echo "Creating /etc/apt/keyrings directory..."
      sudo install -m 0755 -d /etc/apt/keyrings
  else
      echo "/etc/apt/keyrings directory already exists"
  fi

  # Download Docker's GPG key if not already present
  if [ ! -f /etc/apt/keyrings/docker.asc ]; then
      echo "Downloading Docker's GPG key..."
      sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
      sudo chmod a+r /etc/apt/keyrings/docker.asc
  else
      echo "Docker's GPG key already exists"
      # Ensure correct permissions
      sudo chmod a+r /etc/apt/keyrings/docker.asc
  fi

  # Add Docker repository if not already added
  DOCKER_LIST="/etc/apt/sources.list.d/docker.list"
  if [ ! -f "$DOCKER_LIST" ] || ! grep -q "download.docker.com" "$DOCKER_LIST" 2>/dev/null; then
      echo "Adding Docker repository..."
      echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
          $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
          sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  else
      echo "Docker repository already configured"
  fi

  # Update package index with new repository
  sudo apt-get update

  # Install Docker packages
  DOCKER_PACKAGES="docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin"
  echo "Installing Docker packages..."

  # Define packages as an array
  DOCKER_PACKAGES=(
      "docker-ce"
      "docker-ce-cli"
      "containerd.io"
      "docker-buildx-plugin"
      "docker-compose-plugin"
  )

  echo "Installing Docker packages..."
  sudo apt-get install -y "${DOCKER_PACKAGES[@]}"

  # Create docker group if it doesn't exist
  if ! getent group docker > /dev/null 2>&1; then
      echo "Creating docker group..."
      sudo groupadd docker
  else
      echo "Docker group already exists"
  fi

  # Add user to docker group if not already a member
  if ! groups "$USER" | grep -q docker; then
      echo "Adding user $USER to docker group..."
      sudo usermod -aG docker "$USER"
      USER_ADDED_TO_GROUP=true
  else
      echo "User $USER is already in docker group"
      USER_ADDED_TO_GROUP=false
  fi

  # Start Docker service if not running
  if ! systemctl is-active --quiet docker; then
      echo "Starting Docker service..."
      sudo systemctl start docker
  else
      echo "Docker service is already running"
  fi

  # Enable Docker services if not already enabled
  for service in docker.service containerd.service; do
      if ! systemctl is-enabled --quiet $service; then
          echo "Enabling $service..."
          sudo systemctl enable $service
      else
          echo "$service is already enabled"
      fi
  done

  # Verify installation
  if docker --version &> /dev/null; then
      echo "Docker installed successfully: $(docker --version)"
      if [ "$USER_ADDED_TO_GROUP" = true ]; then
          echo "Please log out and back in for group changes to take effect."
      else
          echo "Docker installation is complete!"
      fi
  else
      echo "Docker installation may have failed. Please check the output above."
      return 1
  fi
}

install_podman() {
  echo "Installing Podman..."
  sudo apt -y install podman podman-docker
}

echo "Install Container Runtime"
read -rp "(d)ocker or (p)odman or (n)one [d]: " runtime
case $runtime in
  n|N)
    echo "No Container Runtime"
    ;;
  p|P)
    install_podman
    ;;
  *)
    install_docker
    ;;
esac
