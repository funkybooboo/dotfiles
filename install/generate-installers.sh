#!/usr/bin/env bash
# Package Installer Generator
# Automatically creates individual package installers from packages.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_FILE="$SCRIPT_DIR/packages/packages.sh"
PACKAGES_DIR="$SCRIPT_DIR/packages"

# Source the packages file to get arrays
source "$PACKAGES_FILE"

log() {
    echo "[$(date +'%H:%M:%S')] $*"
}

# Function to determine Arch package manager and name
get_arch_package() {
    local pkg="$1"
    local ubuntu_manager="$2"

    # Map common packages that have different names or are in AUR
    case "$pkg" in
        # Packages available in official repos
        bat|git|wget|curl|kitty|mpv|tree|fzf|jq|ncdu|ripgrep|cmake|clang|pandoc)
            echo "pacman:$pkg"
            ;;
        # fd has different name
        fd-find)
            echo "pacman:fd"
            ;;
        # Packages that need AUR
        obsidian|github-desktop|vscodium-bin|brave-bin|signal-desktop)
            echo "yay:$pkg"
            ;;
        # Language-specific that might be in pacman
        tealdeer)
            echo "pacman:tealdeer"
            ;;
        glow)
            echo "pacman:glow"
            ;;
        lazygit|lazydocker|lazyssh|lazysql)
            # lazygit is in pacman, others in AUR
            if [ "$pkg" = "lazygit" ]; then
                echo "pacman:lazygit"
            else
                echo "yay:$pkg"
            fi
            ;;
        act)
            echo "pacman:act"
            ;;
        # Default: try pacman first
        *)
            echo "pacman:$pkg"
            ;;
    esac
}

# Function to create a package installer
create_installer() {
    local pkg_name="$1"
    local category="$2"
    local ubuntu_pkg="$3"
    local description="$4"

    local output_file="$PACKAGES_DIR/$category/${pkg_name}.sh"

    # Skip if already exists
    if [ -f "$output_file" ]; then
        log "Skipping $pkg_name (already exists)"
        return 0
    fi

    # Determine Arch package
    local arch_pkg=$(get_arch_package "$pkg_name" "${ubuntu_pkg%%:*}")

    # Determine NixOS package (usually same as package name, remove common prefixes)
    local nix_pkg="${pkg_name#python3-}"
    nix_pkg="${nix_pkg%-deb}"

    # Create the installer
    cat > "$output_file" <<EOFINSTALLER
#!/usr/bin/env bash
# PACKAGE: $pkg_name
# DESCRIPTION: $description
# CATEGORY: $category
# UBUNTU_PKG: $ubuntu_pkg
# ARCH_PKG: $arch_pkg
# NIX_PKG: nixpkgs.$nix_pkg
# DEPENDS:
# REBOOT: false

set -euo pipefail

SCRIPT_DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="\$(cd "\$SCRIPT_DIR/../../lib" && pwd)"

source "\$LIB_DIR/distro.sh"
source "\$LIB_DIR/package-manager.sh"
source "\$LIB_DIR/log.sh"

main() {
    log "Installing $pkg_name..."

    case "\$DISTRO" in
        ubuntu)
            if is_package_installed "$pkg_name"; then
                log "$pkg_name is already installed"
                return 0
            fi
            install_package "$ubuntu_pkg"
            ;;
        arch)
            if is_package_installed "$pkg_name"; then
                log "$pkg_name is already installed"
                return 0
            fi
            install_package "$arch_pkg"
            ;;
        nixos)
            log "For NixOS, add '$nix_pkg' to environment.systemPackages in configuration.nix"
            log "Then run: sudo nixos-rebuild switch"
            ;;
        *)
            log "ERROR: Unsupported distribution"
            return 1
            ;;
    esac

    log "$pkg_name installation complete"
}

main "\$@"
EOFINSTALLER

    chmod +x "$output_file"
    log "Created: $output_file"
}

# Create installers for APT packages
log "Creating installers for APT packages..."
for pkg in "${APT_PACKAGES[@]:-}"; do
    [ -z "$pkg" ] && continue
    create_installer "$pkg" "core" "apt:$pkg" "Package from APT repository"
done

# Create installers for Snap packages
log "Creating installers for Snap packages..."
for pkg in "${SNAP_PACKAGES[@]:-}"; do
    [ -z "$pkg" ] && continue
    create_installer "$pkg" "desktop" "snap:$pkg" "Package from Snap store"
done

# Create installers for Snap Classic packages
log "Creating installers for Snap Classic packages..."
for pkg in "${SNAP_CLASSIC_PACKAGES[@]:-}"; do
    [ -z "$pkg" ] && continue
    [[ "$pkg" =~ ^# ]] && continue  # Skip comments
    create_installer "$pkg" "dev" "snap-classic:$pkg" "Package from Snap store (classic confinement)"
done

# Create installers for Flatpak packages
log "Creating installers for Flatpak packages..."
for pkg in "${FLATPAK_PACKAGES[@]:-}"; do
    [ -z "$pkg" ] && continue
    # Extract app name from reverse domain
    app_name=$(echo "$pkg" | awk -F. '{print $NF}' | tr '[:upper:]' '[:lower:]')
    create_installer "$app_name" "desktop" "flatpak:$pkg" "Package from Flathub"
done

# Create installers for Nix packages
log "Creating installers for Nix packages..."
for pkg in "${NIX_PACKAGES[@]:-}"; do
    [ -z "$pkg" ] && continue
    create_installer "$pkg" "dev" "nix:$pkg" "Package from Nix repository"
done

# Create installers for Cargo packages
log "Creating installers for Cargo packages..."
for pkg in "${CARGO_PACKAGES[@]:-}"; do
    [ -z "$pkg" ] && continue
    # Convert underscore to hyphen for filename
    file_pkg="${pkg//_/-}"
    create_installer "$file_pkg" "dev" "cargo:$pkg" "Rust package from crates.io"
done

# Create installers for Go packages
log "Creating installers for Go packages..."
for pkg in "${GO_PACKAGES[@]:-}"; do
    [ -z "$pkg" ] && continue
    # Extract package name from full path
    pkg_name=$(basename "$pkg" | sed 's/@.*//')
    create_installer "$pkg_name" "dev" "go:$pkg" "Go package"
done

# Create installers for Pacstall packages
log "Creating installers for Pacstall packages..."
for pkg in "${PACSTALL_PACKAGES[@]:-}"; do
    [ -z "$pkg" ] && continue
    # Remove -deb suffix for the installer name
    clean_name="${pkg%-deb}"
    create_installer "$clean_name" "dev" "pacstall:$pkg" "Package from Pacstall repository"
done

# Create installers for Homebrew packages
log "Creating installers for Homebrew packages..."
for pkg in "${HOMEBREW_PACKAGES[@]:-}"; do
    [ -z "$pkg" ] && continue
    # Extract package name
    pkg_name=$(basename "$pkg")
    create_installer "$pkg_name" "dev" "brew:$pkg" "Package from Homebrew"
done

# Create installers for NPM packages
log "Creating installers for NPM packages..."
for pkg in "${NPM_PACKAGES[@]:-}"; do
    [ -z "$pkg" ] && continue
    # Extract package name from scoped packages
    pkg_name=$(basename "$pkg" | sed 's/@.*//')
    create_installer "$pkg_name" "dev" "npm:$pkg" "NPM package"
done

log "Package installer generation complete!"
log "Generated installers in: $PACKAGES_DIR"
