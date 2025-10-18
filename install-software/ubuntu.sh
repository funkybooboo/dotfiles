#!/usr/bin/env bash
#
# install-software/os.sh
# Installs common utilities on Ubuntu or Ubuntu-based distros (like Rhino)
#
set -euo pipefail
IFS=$'\n\t'  # safer IFS

TS() { date '+%F %T'; }

echo "[$(TS)] Starting software installation..."

if [[ ! -f "./packages.sh" ]]; then
    echo "[$(TS)] ERROR: packages.sh file not found!"
    exit 1
fi

source "./packages.sh"

# ===============================
# Ensure we are root
# ===============================

if [[ $EUID -ne 0 ]]; then
    echo "[$(TS)] ERROR: Please run this script with sudo"
    exit 1
fi

USER_NAME="${SUDO_USER:-$(whoami)}"
USER_HOME=$(eval echo "~$USER_NAME")

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
# Check internet connectivity
# ===============================

if ! ping -c 1 8.8.8.8 &>/dev/null; then
    echo "[$(TS)] ERROR: No internet connectivity detected. Please check your network."
    exit 1
fi

# ===============================
# Install Package Managers
# ===============================

echo "[$(TS)] Updating APT and installing base dependencies..."

apt update && apt upgrade -y
apt install -y software-properties-common curl wget git sudo ca-certificates gnupg lsb-release apt-transport-https

if ! command -v snap &>/dev/null; then
    echo "[$(TS)] Installing snapd..."
    apt install -y snapd
    systemctl enable --now snapd.socket
fi

if ! command -v flatpak &>/dev/null; then
    echo "[$(TS)] Installing flatpak..."
    apt install -y flatpak
    if ! flatpak remote-list | grep -q "^flathub$"; then
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    fi
fi

if ! command -v pacstall &>/dev/null; then
    echo "[$(TS)] Installing pacstall..."
    curl -fsSL https://pacstall.dev/q/install | bash || {
        echo "[$(TS)] ERROR: pacstall installation failed"
        exit 1
    }
fi

if ! command -v cargo &>/dev/null; then
    echo "[$(TS)] Installing Rust (as $USER_NAME)..."
    sudo -u "$USER_NAME" bash -c "curl https://sh.rustup.rs -sSf | sh -s -- -y"
    export PATH="$USER_HOME/.cargo/bin:$PATH"
fi

if ! command -v go &>/dev/null; then
    echo "[$(TS)] Installing Go..."
    add-apt-repository -y ppa:longsleep/golang-backports
    apt update
    apt install -y golang-go
fi

if ! command -v brew &>/dev/null; then
    echo "[$(TS)] Installing Homebrew..."
    sudo -u "$USER_NAME" bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$($USER_HOME/.linuxbrew/bin/brew shellenv)" || true
fi

if ! command -v gah &>/dev/null; then
    echo "[$(TS)] Installing gah..."
    sudo -u "$USER_NAME" bash -c "$(curl -fsSL https://raw.githubusercontent.com/marverix/gah/refs/heads/master/tools/install.sh)"
fi

# ===============================
# Define install functions and run loops
# ===============================

install_apt_pkg() {
    local pkg=$1
    if ! dpkg -s "$pkg" &>/dev/null; then
        echo "[$(TS)] Installing $pkg via apt..."
        apt install -y "$pkg" || echo "[$(TS)] WARNING: Failed to install $pkg"
    else
        echo "[$(TS)] $pkg already installed (apt)."
    fi
}

echo "[$(TS)] Installing APT packages..."
for pkg in "${APT_PACKAGES[@]}"; do
    install_apt_pkg "$pkg"
done

install_flatpak_pkg() {
    local pkg=$1
    if ! flatpak list | grep -q "^$pkg$"; then
        echo "[$(TS)] Installing $pkg via flatpak..."
        flatpak install -y flathub "$pkg" || echo "[$(TS)] WARNING: Failed to install $pkg"
    else
        echo "[$(TS)] $pkg already installed (flatpak)."
    fi
}

echo "[$(TS)] Installing Flatpak packages..."
for pkg in "${FLATPAK_PACKAGES[@]}"; do
    install_flatpak_pkg "$pkg"
done

install_snap_pkg() {
    local pkg=$1
    if ! snap list | grep -q "^$pkg\s"; then
        echo "[$(TS)] Installing $pkg via snap..."
        snap install "$pkg" || echo "[$(TS)] WARNING: Failed to install $pkg"
    else
        echo "[$(TS)] $pkg already installed (snap)."
    fi
}

echo "[$(TS)] Installing Snap packages..."
for pkg in "${SNAP_PACKAGES[@]}"; do
    install_snap_pkg "$pkg"
done

install_cargo_pkg() {
    local pkg=$1
    if ! cargo install --list | grep -q "^$pkg "; then
        echo "[$(TS)] Installing $pkg via cargo..."
        cargo install "$pkg" || echo "[$(TS)] WARNING: Failed to install $pkg"
    else
        echo "[$(TS)] $pkg already installed (cargo)."
    fi
}

echo "[$(TS)] Installing Cargo packages..."
for pkg in "${CARGO_PACKAGES[@]}"; do
    install_cargo_pkg "$pkg"
done

install_go_pkg() {
    local pkg=$1
    echo "[$(TS)] Installing $pkg via go install..."
    go install "$pkg" || echo "[$(TS)] WARNING: Failed to install $pkg"
}

echo "[$(TS)] Installing Go packages..."
for pkg in "${GO_PACKAGES[@]}"; do
    install_go_pkg "$pkg"
done

install_pacstall_pkg() {
    local pkg=$1
    if ! pacstall --list | grep -q "^~ $pkg$"; then
        echo "[$(TS)] Installing $pkg via pacstall..."
        pacstall -I "$pkg" --yes || echo "[$(TS)] WARNING: Failed to install $pkg"
    else
        echo "[$(TS)] $pkg already installed (pacstall)."
    fi
}

echo "[$(TS)] Installing Pacstall packages..."
for pkg in "${PACSTALL_PACKAGES[@]}"; do
    install_pacstall_pkg "$pkg"
done

install_brew_pkg() {
    local pkg=$1
    if ! brew list | grep -q "^$pkg$"; then
        echo "[$(TS)] Installing $pkg via Homebrew..."
        brew install "$pkg" || echo "[$(TS)] WARNING: Failed to install $pkg"
    else
        echo "[$(TS)] $pkg already installed (brew)."
    fi
}

echo "[$(TS)] Installing Homebrew packages..."
for pkg in "${HOMEBREW_PACKAGES[@]}"; do
    install_brew_pkg "$pkg"
done

install_pip_pkg() {
    local pkg=$1
    if ! pip3 show "$pkg" &>/dev/null; then
        echo "[$(TS)] Installing Python package $pkg..."
        pip3 install --user "$pkg" || echo "[$(TS)] WARNING: Failed to install Python package $pkg"
    else
        echo "[$(TS)] Python package $pkg already installed."
    fi
}

echo "[$(TS)] Installing pip packages..."
for pkg in "${PIP_PACKAGES[@]}"; do
    install_pip_pkg "$pkg"
done

install_npm_pkg() {
    local pkg=$1
    if ! npm list -g --depth=0 | grep -q "^$pkg@"; then
        echo "[$(TS)] Installing npm package $pkg globally..."
        npm install -g "$pkg" || echo "[$(TS)] WARNING: Failed to install npm package $pkg"
    else
        echo "[$(TS)] npm package $pkg already installed globally."
    fi
}

echo "[$(TS)] Installing npm packages..."
for pkg in "${NPM_PACKAGES[@]}"; do
    install_npm_pkg "$pkg"
done

install_gah_pkg() {
    local pkg=$1
    if ! gah list | grep -q "^$pkg$"; then
        echo "[$(TS)] Installing $pkg via gah..."
        if ! gah install "$pkg"; then
            echo "[$(TS)] WARNING: Failed to install gah package $pkg"
        fi
    else
        echo "[$(TS)] $pkg already installed (gah)."
    fi
}

echo "[$(TS)] Installing gah packages..."
for pkg in "${GAH_PACKAGES[@]}"; do
    install_gah_pkg "$pkg"
done

install_jetbrains_toolbox() {
    echo "[$(TS)] Checking JetBrains Toolbox installation..."

    local install_dir="/opt/jetbrains-toolbox"
    local symlink_path="/usr/local/bin/jetbrains-toolbox"

    if [[ -x "$install_dir/jetbrains-toolbox" && "$(readlink -f "$symlink_path" 2>/dev/null)" == "$install_dir/jetbrains-toolbox" ]]; then
        echo "[$(TS)] JetBrains Toolbox already installed."
        return 0
    fi

    echo "[$(TS)] Installing JetBrains Toolbox..."

    local toolbox_url="https://data.services.jetbrains.com/products/download?code=TBA&platform=linux"
    local tmp_dir="/tmp/jetbrains-toolbox"

    rm -rf "$tmp_dir"
    mkdir -p "$tmp_dir"

    if ! wget -qO- "$toolbox_url" | tar -xz -C "$tmp_dir" --strip-components=1; then
        echo "[$(TS)] ERROR: Failed to download or extract JetBrains Toolbox."
        return 1
    fi

    if [[ ! -x "$tmp_dir/jetbrains-toolbox" ]]; then
        echo "[$(TS)] ERROR: Downloaded JetBrains Toolbox binary not found or not executable."
        return 1
    fi

    rm -rf "$install_dir"
    mv "$tmp_dir" "$install_dir"
    chmod +x "$install_dir/jetbrains-toolbox"

    ln -sf "$install_dir/jetbrains-toolbox" "$symlink_path"

    echo "[$(TS)] JetBrains Toolbox installed successfully."
}

install_jetbrains_toolbox

echo "[$(TS)] ✅ Software installation complete."
