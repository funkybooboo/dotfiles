#!/usr/bin/env bash

set -e
set -o pipefail

install_ollama() {
    echo "Installing Ollama + Open WebUI..."

    # Check if Docker is available for WebUI
    if ! command -v docker &> /dev/null; then
        echo "Error: Docker is required for Open WebUI but not installed. Please install Docker first."
        return 1
    fi

    # Install/Reinstall Ollama
    echo "Installing Ollama..."
    if curl -fsSL https://ollama.com/install.sh | sh; then
        echo "Ollama installed successfully"
        # Start ollama service
        sudo systemctl start ollama 2>/dev/null || true
        sudo systemctl enable ollama 2>/dev/null || true
    else
        echo "Error: Failed to install Ollama"
        return 1
    fi

    # Install/Reinstall Open WebUI
    echo "Installing Open WebUI..."

    # Remove existing container if it exists
    if docker ps -a --format "{{.Names}}" 2>/dev/null | grep -q "^open-webui$"; then
        echo "Removing existing Open WebUI container..."
        docker stop open-webui 2>/dev/null || true
        docker rm open-webui 2>/dev/null || true
    fi

    if docker run -d --network=host -v open-webui:/app/backend/data -e OLLAMA_BASE_URL=http://127.0.0.1:11434 --name open-webui --restart always ghcr.io/open-webui/open-webui:main; then
        echo "Open WebUI installed successfully"
        echo "Access it at: http://localhost:8080"
    else
        echo "Error: Failed to install Open WebUI"
        return 1
    fi

    return 0
}
install_claude() {
    if [[ "$CLAUDE_INSTALLED" = true ]]; then
        read -rp "Claude CLI is already installed. Reinstall? (y/N): " reinstall
        if [[ ! "$reinstall" =~ ^[Yy]$ ]]; then
            echo "Skipping Claude CLI installation"
            echo "Run 'claude --help' to get started"
            return 0
        fi
    fi
    echo "Installing Claude CLI..."
    # https://github.com/anthropics/claude-code
    # Check if npm is available
    if ! command -v npm &> /dev/null; then
        echo "Error: npm is required for Claude CLI but not installed. Please install Node.js/npm first."
        return 1
    fi
    if sudo npm install -g @anthropic-ai/claude-code; then
        echo "Claude CLI installed successfully"
        echo "Run 'claude --help' to get started"
        return 0
    else
        echo "Error: Failed to install Claude CLI"
        return 1
    fi
}

echo "Setup LLM"
read -rp "(o)llama + openwebui or (c)laude cli or (b)oth or (n)one [n]: " llm_choice

case $llm_choice in
  o|O)
    install_ollama
    ;;
  c|C)
    install_claude
    ;;
  b|B)
    install_ollama
    install_claude
    ;;
  *)
    echo "No LLM setup selected"
    ;;
esac
