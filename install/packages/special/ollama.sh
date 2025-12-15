#!/usr/bin/env bash

set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/log.sh"

install_ollama() {
    log "Installing Ollama + Open WebUI..."

    # Check for Docker
    if ! command -v docker &>/dev/null; then
        log "Error: Docker is required for Open WebUI but not installed. Please install Docker first."
        return 1
    fi

    # Install Ollama
    log "Installing Ollama..."
    if curl -fsSL https://ollama.com/install.sh | sh; then
        log "Ollama installed successfully"
        sudo systemctl start ollama 2>/dev/null || true
        sudo systemctl enable ollama 2>/dev/null || true
    else
        log "Error: Failed to install Ollama"
        return 1
    fi

    # Install Open WebUI
    log "Installing Open WebUI..."

    # Remove existing container if present
    if docker ps -a --format "{{.Names}}" 2>/dev/null | grep -q "^open-webui$"; then
        log "Removing existing Open WebUI container..."
        docker stop open-webui 2>/dev/null || true
        docker rm open-webui 2>/dev/null || true
    fi

    if docker run -d \
        --network=host \
        -v open-webui:/app/backend/data \
        -e OLLAMA_BASE_URL=http://127.0.0.1:11434 \
        --name open-webui \
        --restart always \
        ghcr.io/open-webui/open-webui:main; then
        log "Open WebUI installed successfully"
        log "Access it at: http://localhost:8080"
    else
        log "Error: Failed to install Open WebUI"
        return 1
    fi
}
install_ollama
