#!/usr/bin/env bash
#
# install-software/os.sh
# Installs common utilities on Ubuntu or Ubuntu-based distros (like Rhino)
#
set -euo pipefail
IFS=$'\n\t'  # safer IFS

# Ensure USER and HOME are defined for script and subprocesses
: "${USER:=$(id -un)}"
: "${HOME:=$(getent passwd "$USER" | cut -d: -f6)}"
export USER HOME


TS() { date '+%F %T'; }

# Function to add path to bash and fish configs idempotently.
# Pass just the directory path; bash and fish logic handle syntax.
add_path_bash_and_fish() {
  local newpath="$1"
  local bash_line="export PATH=\"$newpath:\$PATH\""
  # Add to bash profile (~/.profile) if not already present
  if ! grep -Fxq "$bash_line" ~/.profile 2>/dev/null; then
    echo "$bash_line" >> ~/.profile
  fi

  # For fish shell, add equivalent fish_add_path to config.fish if fish is installed
  if command -v fish &>/dev/null; then
    local fish_cfg="$HOME/.config/fish/config.fish"
    mkdir -p "$(dirname "$fish_cfg")"
    # Add line only if newpath not already present
    if ! grep -Fq "$newpath" "$fish_cfg" 2>/dev/null; then
      echo "fish_add_path --prepend $newpath" >> "$fish_cfg"
    fi
  fi
}

# Function to add eval commands (e.g. Homebrew shellenv) idempotently
add_eval_bash_and_fish() {
  local eval_cmd="$1"
  # Add to bash profile if missing
  if ! grep -Fxq "$eval_cmd" ~/.profile 2>/dev/null; then
    echo "$eval_cmd" >> ~/.profile
  fi

  # Add to fish config if missing
  if command -v fish &>/dev/null; then
    local fish_cfg="$HOME/.config/fish/config.fish"
    mkdir -p "$(dirname "$fish_cfg")"
    # We use fish syntax for eval with psub
    local fish_line="eval ( $eval_cmd | psub )"
    if ! grep -Fq "$eval_cmd" "$fish_cfg" 2>/dev/null; then
      echo "$fish_line" >> "$fish_cfg"
    fi
  fi
}

echo "[$(TS)] Starting software installation..."

if [[ ! -f "./packages.sh" ]]; then
    echo "[$(TS)] ERROR: packages.sh file not found!"
    exit 1
fi

source "./packages.sh"

# ===============================
# Detect Distro
# ===============================

if [[ -f /etc/os-release ]]; then
    # shellcheck source=/dev/null
    source /etc/os-release
    if [[ "$ID" =~ ^(ubuntu|rhino)$ || "$ID_LIKE" =~ debian ]]; then
        DISTRO="Ubuntu"
    else
        echo "[$(TS)] Unsupported distro: $ID"
        exit 1
    fi
else
    echo "[$(TS)] Cannot detect OS."
    exit 1
fi

echo "[$(TS)] Detected distro: $DISTRO"
echo ""

# ===============================
# Install Package Managers (using sudo for system-level commands)
# ===============================

echo "[$(TS)] Updating APT and installing base dependencies..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y software-properties-common curl wget git sudo ca-certificates gnupg lsb-release apt-transport-https

# ===============================
# Install snapd (requires sudo)
# ===============================

if ! command -v snap &>/dev/null; then
    echo "[$(TS)] Installing snapd..."
    sudo apt install -y snapd
    sudo systemctl enable --now snapd.socket
fi

# ===============================
# Install Flatpak (requires sudo)
# ===============================

if ! command -v flatpak &>/dev/null; then
    echo "[$(TS)] Installing flatpak..."
    sudo apt install -y flatpak
    if ! flatpak remote-list | grep -q "^flathub$"; then
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    fi
fi

# ===============================
# Install pacstall (requires sudo)
# ===============================

if ! command -v pacstall &>/dev/null; then
    echo "[$(TS)] Installing pacstall..."
    curl -fsSL https://pacstall.dev/q/install | bash || {
        echo "[$(TS)] ERROR: pacstall installation failed"
        exit 1
    }
fi

# ===============================
# Install Rust (without sudo)
# ===============================

if ! command -v cargo &>/dev/null; then
    echo "[$(TS)] Installing Rust (as $USER)..."
    curl https://sh.rustup.rs -sSf | bash -s -- -y
    add_path_bash_and_fish "$HOME/.cargo/bin"
    rustup default stable
fi

# ===============================
# Install Go (without sudo)
# ===============================

if ! command -v go &>/dev/null; then
    echo "[$(TS)] Installing Go..."
    wget https://go.dev/dl/go1.19.6.linux-amd64.tar.gz -P /tmp
    sudo tar -C /usr/local -xzf /tmp/go1.19.6.linux-amd64.tar.gz
    add_path_bash_and_fish "/usr/local/go/bin"
    go version
fi

# ===============================
# Install Homebrew (without sudo)
# ===============================

# if ! command -v brew &>/dev/null; then
#     echo "[$(TS)] Installing Homebrew"
#
#     TERM=xterm-256color HOME="$HOME" USER="$USER" /bin/bash -i -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
#
#     local brew_eval_cmd='eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'
#     add_eval_bash_and_fish "$brew_eval_cmd"
#     eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
# else
#     echo "[$(TS)] Homebrew is already installed."
# fi

# ===============================
# Ensure Homebrew Tap for lazyssh is added
# ===============================

# if ! brew tap | grep -q "^Adembc/homebrew-tap$"; then
#     echo "[$(TS)] Adding homebrew-tap for lazyssh..."
#     brew tap Adembc/homebrew-tap
# fi

# ===============================
# Define Install Functions
# ===============================

install_apt_pkg() {
    local pkg=$1
    if ! dpkg -s "$pkg" &>/dev/null; then
        echo "[$(TS)] Installing $pkg via APT..."
        sudo apt install -y "$pkg" || echo "[$(TS)] WARNING: Failed to install $pkg"
    else
        echo "[$(TS)] $pkg already installed (apt)."
    fi
}

install_flatpak_pkg() {
    local pkg=$1
    if ! flatpak list | grep -q "$pkg"; then
        echo "[$(TS)] Installing $pkg via Flatpak..."
        flatpak install -y flathub "$pkg" || echo "[$(TS)] WARNING: Failed to install $pkg"
    else
        echo "[$(TS)] $pkg already installed (flatpak)."
    fi
}

install_snap_pkg() {
    local pkg=$1
    if ! snap list | grep -q "^$pkg[[:space:]]"; then
        echo "[$(TS)] Installing $pkg via Snap..."
        if [ "$pkg" = "yazi" ]; then
            sudo snap install "$pkg" --classic || echo "[$(TS)] WARNING: Failed to install $pkg"
        else
            sudo snap install "$pkg" || echo "[$(TS)] WARNING: Failed to install $pkg"
        fi
    else
        echo "[$(TS)] $pkg already installed (snap)."
    fi
}

install_pacstall_pkg() {
    local pkg=$1
    if ! pacstall --list | grep -q "^$pkg\$"; then
        echo "[$(TS)] Installing $pkg via Pacstall..."
        pacstall --install "$pkg" || echo "[$(TS)] WARNING: Failed to install $pkg"
    else
        echo "[$(TS)] $pkg already installed (pacstall)."
    fi
}

# install_brew_pkg() {
#     local pkg=$1
#     echo "[$(TS)] Checking if $pkg is installed..."
#     if ! brew list "$pkg" &>/dev/null; then
#         echo "[$(TS)] Installing $pkg via Homebrew..."
#         brew install "$pkg" || echo "[$(TS)] WARNING: Failed to install $pkg"
#     else
#         echo "[$(TS)] $pkg already installed (brew)."
#     fi
# }

install_pip_pkg() {
    local pkg=$1
    if ! pip3 show "$pkg" &>/dev/null; then
        echo "[$(TS)] Installing Python package $pkg..."
        pip3 install --user "$pkg" || echo "[$(TS)] WARNING: Failed to install Python package $pkg"
    else
        echo "[$(TS)] Python package $pkg already installed."
    fi
}

install_npm_pkg() {
    local pkg=$1
    if ! npm list -g --depth=0 | grep -q "^$pkg@"; then
        echo "[$(TS)] Installing npm package $pkg globally..."
        npm install -g "$pkg" || echo "[$(TS)] WARNING: Failed to install npm package $pkg"
    else
        echo "[$(TS)] npm package $pkg already installed globally."
    fi
}

# ===============================
# Install Packages
# ===============================

echo "[$(TS)] Installing apt packages..."
for pkg in "${APT_PACKAGES[@]}"; do
    install_apt_pkg "$pkg"
done

echo "[$(TS)] Installing flatpak packages..."
for pkg in "${FLATPAK_PACKAGES[@]}"; do
    install_flatpak_pkg "$pkg"
done

echo "[$(TS)] Installing snap packages..."
for pkg in "${SNAP_PACKAGES[@]}"; do
    install_snap_pkg "$pkg"
done

echo "[$(TS)] Installing pacstall packages..."
for pkg in "${PACSTALL_PACKAGES[@]}"; do
    install_pacstall_pkg "$pkg"
done

# echo "[$(TS)] Installing Homebrew packages..."
# for pkg in "${HOMEBREW_PACKAGES[@]}"; do
#     install_brew_pkg "$pkg"
# done

echo "[$(TS)] Installing Python packages..."
for pkg in "${PIP_PACKAGES[@]}"; do
    install_pip_pkg "$pkg"
done

echo "[$(TS)] Installing npm packages..."
for pkg in "${NPM_PACKAGES[@]}"; do
    install_npm_pkg "$pkg"
done

# ===============================
# JetBrains Toolbox Installation
# ===============================

install_jetbrains_toolbox() {
    TMP_DIR="/tmp"
    INSTALL_DIR="$HOME/.local/share/JetBrains/Toolbox"
    SYMLINK_DIR="$HOME/.local/bin"

    echo "### INSTALL JETBRAINS TOOLBOX ###"

    ARCHIVE_URL=$(curl -s 'https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release' | grep -Po '"linux":.*?[^\\]",' | awk -F ':' '{print $3,":"$4}'| sed 's/[", ]//g')
    ARCHIVE_FILENAME=$(basename "$ARCHIVE_URL")

    # Download idempotently (remove old file if exists)
    if [[ ! -f "$TMP_DIR/$ARCHIVE_FILENAME" ]]; then
        echo "Downloading $ARCHIVE_FILENAME..."
        wget -q -cO "$TMP_DIR/$ARCHIVE_FILENAME" "$ARCHIVE_URL"
    fi

    echo "Extracting to $INSTALL_DIR..."
    mkdir -p "$INSTALL_DIR"
    rm -rf "$INSTALL_DIR"/*
    tar -xzf "$TMP_DIR/$ARCHIVE_FILENAME" -C "$INSTALL_DIR" --strip-components=1
    chmod +x "$INSTALL_DIR/bin/jetbrains-toolbox"

    echo "Creating symlink..."
    mkdir -p "$SYMLINK_DIR"
    ln -sfn "$INSTALL_DIR/bin/jetbrains-toolbox" "$SYMLINK_DIR/jetbrains-toolbox"

    echo "JetBrains Toolbox installed successfully. Run via 'jetbrains-toolbox' command."
    nohup jetbrains-toolbox &
}
install_jetbrains_toolbox

echo "[$(TS)] ✅ Software installation complete."
