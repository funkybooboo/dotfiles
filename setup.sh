#!/usr/bin/env bash
set -euo pipefail

# ─── Locate this script and cd into its directory ──────────────────────────────
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

# ─── Prerequisites ──────────────────────────────────────────────────────────────
if ! command -v jq &>/dev/null; then
    echo "❌  jq not found. Install it (e.g. 'sudo apt install jq') and re-run."
    exit 1
fi

if ! command -v stow &>/dev/null; then
    echo "❌  GNU stow not found. Install it (e.g. 'sudo apt install stow') and re-run."
    exit 1
fi

# ─── Read config.json for binaries to expose ────────────────────────────────────
BINARIES=($(jq -r '.["add-to-path"][]' config.json))

# ─── Define HOME and ROOT package arrays ────────────────────────────────────────
HOME_PACKAGES=(
    bash
    config
    gdbinit
    ideavim
    scripts
    vim
    git
    jump
    alejandra
)

# Debugging output to check package names
echo "Home packages to be stowed: ${HOME_PACKAGES[*]}"

# ─── Backup any existing targets before we touch them ────────────────────────────
TS=$(date +%Y%m%d%H%M%S)
BACKUP_DIR="$HOME/dotfiles/stow-backups/$TS"
echo "💾  Backing up existing files to $BACKUP_DIR …"
mkdir -p "$BACKUP_DIR"

# 1) Home-targeted packages
for pkg in "${HOME_PACKAGES[@]}"; do
    find "$DOTFILES_DIR/$pkg" -mindepth 1 | while read -r src; do
        rel=${src#"$DOTFILES_DIR/$pkg/"} # path relative inside package
        dest="$HOME/$rel"
        if [ -e "$dest" ]; then # Only backup if it exists
            if [ -L "$dest" ]; then
                # Handle symlinks separately
                echo "Skipping symlink: $dest"
            else
                backup_dest="$BACKUP_DIR/$rel"
                # Check if the destination is a file or directory
                if [ -d "$dest" ]; then
                    timestamped_backup="$BACKUP_DIR/${rel}_$(date +%Y%m%d%H%M%S)"
                    mkdir -p "$(dirname "$timestamped_backup")"
                    cp -r "$dest" "$timestamped_backup" # Copy directory
                    echo "  backed up: $dest → $timestamped_backup"
                elif [ -f "$dest" ]; then
                    timestamped_backup="$BACKUP_DIR/${rel}_$(date +%Y%m%d%H%M%S)"
                    mkdir -p "$(dirname "$timestamped_backup")"
                    cp "$dest" "$timestamped_backup" # Copy file
                    echo "  backed up: $dest → $timestamped_backup"
                fi
            fi
        fi
    done
done

echo ""

# ─── Stow into $HOME, force-overwriting any existing files/links ───────────────
echo "🔗  Stowing to \$HOME: ${HOME_PACKAGES[*]}"
for pkg in "${HOME_PACKAGES[@]}"; do
    echo "Stowing package: $pkg" # Debugging output
    if [ -z "$pkg" ]; then
        echo "Skipping empty package: $pkg"
        continue
    fi
    stow \
        --verbose \
        --target="$HOME" \
        --restow \
        "$pkg"
done

# ─── Link only Pictures/wallpapers into ~/Pictures/wallpapers ─────────────────
echo ""
echo "🔗  Linking wallpapers into \$HOME/Pictures/wallpapers"
mkdir -p "$HOME/Pictures"
rm -rf "$HOME/Pictures/wallpapers"
ln -s "$DOTFILES_DIR/Pictures/wallpapers" "$HOME/Pictures/wallpapers"

# ─── Expose configured scripts into ~/.local/bin ────────────────────────────────
echo ""
echo "🔧  Adding scripts from config.json into ~/.local/bin"
mkdir -p "$HOME/.local/bin"
for rel in "${BINARIES[@]}"; do
    if [ -z "$rel" ]; then
        echo "Skipping empty binary: $rel"
        continue
    fi
    src="$DOTFILES_DIR/$rel"
    dst="$HOME/.local/bin/$(basename "$rel")"
    rm -f "$dst"
    ln -s "$src" "$dst"
    echo "  LINK: $dst → $src"
done

echo ""
echo "✅  All done!  (backups in $BACKUP_DIR)"
