#!/usr/bin/env bash
set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/log.sh"
source "$SCRIPT_DIR/../utils/shell-configs.sh"  # for add_path_bash_and_fish/add_eval_bash_and_fish

log "Installing package managers..."

install_snapd() {
    if ! command -v snap &>/dev/null; then
        log "Installing snapd..."
        sudo apt install -y snapd
        sudo systemctl enable --now snapd.socket
    else
        log "snapd is already installed."
    fi
}

install_flatpak() {
    if ! command -v flatpak &>/dev/null; then
        log "Installing flatpak..."
        sudo apt install -y flatpak
        if ! flatpak remote-list | grep -q "^flathub$"; then
            flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        fi
    else
        log "flatpak is already installed."
    fi
}

install_nix() {
    if ! command -v nix-env &>/dev/null; then
        log "Installing Nix package manager..."
        
        # Install Nix multi-user (daemon) mode
        sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon
        
        # Source Nix daemon environment
        if [ -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]; then
            . "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
        fi

        add_path_bash_and_fish "/nix/var/nix/profiles/default/bin"
        log "Nix installed successfully: $(nix-env --version)"
    else
        log "Nix is already installed."
    fi
}

install_pacstall() {
    if ! command -v pacstall &>/dev/null; then
        log "Installing pacstall..."
        sudo bash -c "$(curl -fsSL https://pacstall.dev/q/install || wget -q https://pacstall.dev/q/install -O -)"
    else
        log "pacstall is already installed."
    fi
}

install_homebrew() {
    if ! command -v brew &>/dev/null; then
        log "Installing Homebrew..."
        /bin/bash -i -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        local brew_eval_cmd='eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'
        add_eval_bash_and_fish "$brew_eval_cmd"
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        log "Homebrew installed successfully: $(brew --version)"
    else
        log "Homebrew is already installed."
    fi
}

install_rust() {
    if ! command -v cargo &>/dev/null; then
        log "Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
        add_path_bash_and_fish "$HOME/.cargo/bin"
        log "Rust installed successfully: $(rustc --version)"
    else
        log "Rust is already installed."
    fi
}

install_go() {
    if ! command -v go &>/dev/null; then
        log "Installing Go..."
        sudo apt install golang
        log "Go installed successfully: $(go version)"
    else
        log "Go is already installed."
    fi
}

install_asdf() {
    if ! command -v asdf &>/dev/null; then
        log "Installing asdf..."
        brew install asdf
        log "asdf installed successfully: $(asdf --version)"

        add_path_bash_and_fish "$HOME/.asdf/shims"
    else
        log "asdf is already installed."
    fi
}

install_python() {
    # Add plugin if not already added
    if ! asdf plugin list | grep -q "^python$"; then
        asdf plugin add python https://github.com/asdf-community/asdf-python.git
    else
        echo "Python plugin already added"
    fi

    TARGET_VERSION="3.11.14"
    asdf install python "$TARGET_VERSION"
    asdf set -u python "$TARGET_VERSION"

    add_path_bash_and_fish "$HOME/.asdf/shims"
}

install_node() {
    # Add plugin if not already added
    if ! asdf plugin list | grep -q "^nodejs$"; then
        asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
    else
        echo "Node.js plugin already added"
    fi

    TARGET_VERSION="23.11.1"
    asdf install nodejs "$TARGET_VERSION"
    asdf set -u nodejs "$TARGET_VERSION"

    add_path_bash_and_fish "$HOME/.asdf/shims"
}

# Install all package managers
install_snapd
install_flatpak
install_nix
install_pacstall
install_homebrew
install_rust
install_go
install_asdf
install_python
install_node

log "All package managers installation complete!"
