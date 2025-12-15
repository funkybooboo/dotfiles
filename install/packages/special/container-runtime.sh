#!/usr/bin/env bash

set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/log.sh"

install_docker() {
    log "Installing Docker..."

    # Check if Docker is installed
    if command -v docker &>/dev/null && docker --version &>/dev/null; then
        log "Docker is already installed: $(docker --version)"

        # Start service if not running
        if ! systemctl is-active --quiet docker; then
            log "Starting Docker service..."
            sudo systemctl start docker
        else
            log "Docker service already running"
        fi

        # Add user to docker group if not a member
        if ! groups "$USER" | grep -q docker; then
            log "Adding user $USER to docker group..."
            sudo usermod -aG docker "$USER"
            log "Please log out and back in for group changes to take effect"
        else
            log "User $USER already in docker group"
        fi

        log "Docker installation is up to date"
        return 0
    fi

    log "Docker not found, proceeding with installation..."

    # Update package index
    sudo apt-get update

    # Install prerequisites
    for pkg in ca-certificates curl gnupg lsb-release; do
        if ! dpkg -l | grep -q "^ii  $pkg "; then
            log "Installing $pkg..."
            sudo apt-get install -y "$pkg"
        else
            log "$pkg already installed"
        fi
    done

    # Keyrings directory
    sudo mkdir -p /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add Docker repo
    DOCKER_LIST="/etc/apt/sources.list.d/docker.list"
    if [ ! -f "$DOCKER_LIST" ] || ! grep -q "download.docker.com" "$DOCKER_LIST"; then
        log "Adding Docker repository..."
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
          $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
          sudo tee "$DOCKER_LIST" > /dev/null
    else
        log "Docker repository already configured"
    fi

    sudo apt-get update

    # Install Docker packages
    local DOCKER_PACKAGES=(
        docker-ce
        docker-ce-cli
        containerd.io
        docker-buildx-plugin
        docker-compose-plugin
    )
    sudo apt-get install -y "${DOCKER_PACKAGES[@]}"

    # Ensure docker group exists
    if ! getent group docker > /dev/null 2>&1; then
        sudo groupadd docker
    fi

    # Add user to group if not already
    if ! groups "$USER" | grep -q docker; then
        sudo usermod -aG docker "$USER"
        log "User $USER added to docker group. Please log out and back in."
    fi

    # Start and enable services
    for svc in docker containerd; do
        sudo systemctl start "$svc"
        sudo systemctl enable "$svc"
    done

    if docker --version &>/dev/null; then
        log "Docker installed successfully: $(docker --version)"
    else
        log "Docker installation may have failed"
        return 1
    fi
}

install_podman() {
    log "Installing Podman..."
    sudo apt-get install -y podman podman-docker
}

# Prompt user
log "Install Container Runtime"
read -rp "(d)ocker or (p)odman or (n)one [d]: " runtime

case $runtime in
    n|N)
        log "No Container Runtime selected"
        ;;
    p|P)
        install_podman
        ;;
    *)
        install_docker
        ;;
esac
