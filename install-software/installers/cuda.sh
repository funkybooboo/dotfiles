#!/usr/bin/env bash

set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/log.sh"

install_cuda_ubuntu() {
    log "Starting CUDA installation..."

    # Check for NVIDIA GPU
    if ! lspci | grep -i nvidia &>/dev/null; then
        log "No NVIDIA GPU detected, skipping CUDA installation"
        return 0
    fi
    log "NVIDIA GPU detected"

    # Check if drivers are already working
    if nvidia-smi &>/dev/null; then
        log "NVIDIA drivers already installed and working:"
        nvidia-smi --query-gpu=name,driver_version,cuda_version --format=csv,noheader

        # Check if CUDA toolkit is installed
        if command -v nvcc &>/dev/null; then
            log "CUDA toolkit already installed:"
            nvcc --version | grep "release"
        else
            log "NVIDIA drivers working, but CUDA toolkit not found. Installing CUDA toolkit..."
            sudo apt update
            sudo apt install -y nvidia-cuda-toolkit
            log "CUDA toolkit installation complete"
        fi
        return 0
    fi

    # Check if NVIDIA drivers installed but not loaded (reboot required)
    if dpkg -l | grep -q "nvidia-driver" && [ ! -c /dev/nvidia0 ]; then
        log "NVIDIA drivers appear installed but not loaded."
        log "REBOOT REQUIRED: Please restart your system to load the NVIDIA drivers."
        log "After reboot, verify installation with: nvidia-smi"
        return 0
    fi

    log "Installing NVIDIA drivers and CUDA toolkit..."

    # Update package database
    sudo apt update

    # Ensure ubuntu-drivers-common is installed
    if ! command -v ubuntu-drivers &>/dev/null; then
        log "Installing ubuntu-drivers-common..."
        sudo apt install -y ubuntu-drivers-common
    fi

    # Install recommended NVIDIA drivers
    log "Installing recommended NVIDIA drivers..."
    sudo ubuntu-drivers autoinstall

    # Install CUDA toolkit
    log "Installing CUDA toolkit..."
    sudo apt install -y nvidia-cuda-toolkit

    log "CUDA installation complete."
    log "REBOOT REQUIRED: Please restart your system to load the NVIDIA drivers."
    log "After reboot, verify installation with: nvidia-smi"
}

install_cuda_ubuntu
