#!/usr/bin/env bash

set -e
set -o pipefail

# Install CUDA drivers if NVIDIA GPU is present (Ubuntu only)
install_cuda_ubuntu() {
    # Check for NVIDIA GPU
    if ! lspci | grep -i nvidia &> /dev/null; then
        echo "No NVIDIA GPU detected, skipping CUDA installation"
        return 0
    fi
    echo "NVIDIA GPU detected"
    # Check if drivers are already working
    if nvidia-smi &> /dev/null; then
        echo "NVIDIA drivers already installed and working:"
        nvidia-smi --query-gpu=name,driver_version,cuda_version --format=csv,noheader
        # Check if CUDA toolkit is installed
        if command -v nvcc &> /dev/null; then
            echo "CUDA toolkit already installed:"
            nvcc --version | grep "release"
        else
            echo "NVIDIA drivers working, but CUDA toolkit not found. Installing CUDA toolkit..."
            sudo apt update
            if ! sudo apt install -y nvidia-cuda-toolkit; then
                echo "Error: Failed to install CUDA toolkit"
                return 1
            fi
            echo "CUDA toolkit installation complete"
        fi
        return 0
    fi
    # Check if NVIDIA drivers are installed but not loaded (might need reboot)
    if dpkg -l | grep -q "nvidia-driver" && [ ! -c /dev/nvidia0 ]; then
        echo "NVIDIA drivers appear to be installed but not loaded."
        echo "REBOOT REQUIRED: Please restart your system to load the NVIDIA drivers."
        echo "After reboot, verify installation with: nvidia-smi"
        return 0
    fi
    echo "Installing NVIDIA drivers and CUDA toolkit..."

    # Update package database
    if ! sudo apt update; then
        echo "Error: Failed to update package database"
        return 1
    fi
    # Check if ubuntu-drivers is available
    if ! command -v ubuntu-drivers &> /dev/null; then
        echo "Installing ubuntu-drivers-common..."
        sudo apt install -y ubuntu-drivers-common
    fi
    # Install recommended drivers automatically
    echo "Installing recommended NVIDIA drivers..."
    if ! sudo ubuntu-drivers autoinstall; then
        echo "Error: Failed to install NVIDIA drivers"
        return 1
    fi
    # Install CUDA toolkit if not already installed
    echo "Installing CUDA toolkit..."
    if ! sudo apt install -y nvidia-cuda-toolkit; then
        echo "Error: Failed to install CUDA toolkit"
        return 1
    fi
    echo "CUDA installation complete."
    echo "REBOOT REQUIRED: Please restart your system to load the NVIDIA drivers."
    echo "After reboot, verify installation with: nvidia-smi"
}
install_cuda_ubuntu
