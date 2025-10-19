#!/usr/bin/env bash

set -e
set -o pipefail

echo "Install Java"

# Check if Adoptium repository is already configured
check_adoptium_repo() {
    if [ -f /etc/apt/sources.list.d/adoptium.list ]; then
        echo "Adoptium repository already configured"
        return 0
    fi
    return 1
}
# Check if GPG key is already installed
check_adoptium_gpg() {
    if [ -f /etc/apt/trusted.gpg.d/adoptium.gpg ]; then
        echo "Adoptium GPG key already installed"
        return 0
    fi
    return 1
}
# Add GPG key if not present
add_adoptium_gpg() {
    if check_adoptium_gpg; then
        return 0
    fi
    echo "Adding Adoptium GPG key..."
    if ! wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | sudo gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/adoptium.gpg > /dev/null; then
        echo "Error: Failed to add GPG key"
        return 1
    fi
    echo "GPG key added successfully"
}
# Add repository if not present
add_adoptium_repo() {
    if check_adoptium_repo; then
        return 0
    fi
    echo "Adding Adoptium repository..."
    local ubuntu_codename="oracular"
    echo "deb https://packages.adoptium.net/artifactory/deb $ubuntu_codename main" | sudo tee /etc/apt/sources.list.d/adoptium.list > /dev/null
    echo "Repository added for $ubuntu_codename"
}
# Setup Adoptium repository and GPG key
setup_adoptium() {
    local needs_update=false
    if ! check_adoptium_gpg; then
        add_adoptium_gpg || return 1
        needs_update=true
    fi
    if ! check_adoptium_repo; then
        add_adoptium_repo || return 1
        needs_update=true
    fi
    if $needs_update; then
        echo "Updating package lists..."
        sudo apt update
    fi
}

# Get desired Java version
DEFAULT_VERSION=21
read -rp "What version of Java do you want? [${DEFAULT_VERSION}]: " JAVACORE_VERSION
# Use default if input is empty or invalid
if [[ ! $JAVACORE_VERSION =~ ^[0-9]+$ ]]; then
    echo "Using default Java version: ${DEFAULT_VERSION}"
    JAVACORE_VERSION=${DEFAULT_VERSION}
fi
# Check if specific version is already installed
specific_version_installed=false
if dpkg -l | grep -q "temurin-${JAVACORE_VERSION}-jdk"; then
    echo "Temurin JDK ${JAVACORE_VERSION} is already installed"
    specific_version_installed=true
fi
# Install if not already present
if ! $specific_version_installed; then
    echo "Installing Java ${JAVACORE_VERSION}..."
    # Setup repository if needed
    if ! setup_adoptium; then
        echo "Error: Failed to setup Adoptium repository"
        exit 1
    fi
    # Check if the requested version is available
    if ! apt-cache show "temurin-${JAVACORE_VERSION}-jdk" &> /dev/null; then
        echo "Error: Java version ${JAVACORE_VERSION} is not available in the repository"
        echo "Available versions:"
        apt-cache search "temurin.*jdk" | grep -o "temurin-[0-9]*-jdk" | sort
        exit 1
    fi
    # Install the requested version
    if sudo apt install -y "temurin-${JAVACORE_VERSION}-jdk"; then
        echo "Java ${JAVACORE_VERSION} installed successfully"
        # Show installation verification
        echo "Verifying installation..."
        java -version 2>&1 | head -n 3
        echo ""
        echo "Exporting JAVA_HOME..."
        ./append_config.sh "export JAVA_HOME=/usr/lib/jvm/temurin-${JAVACORE_VERSION}-jdk-amd64"
    else
        echo "Error: Failed to install Java ${JAVACORE_VERSION}"
        exit 1
    fi
fi
