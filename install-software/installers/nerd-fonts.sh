#!/usr/bin/env bash

set -e
set -o pipefail

FONT_DIR="$HOME/.fonts"
mkdir -p "$FONT_DIR"
TEMP_DIR=$(mktemp -d)

declare -A fonts_urls=(
  ["JetBrainsMono"]="https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/JetBrainsMono.zip"
  ["FiraCode"]="https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/FiraCode.zip"
  ["OpenDyslexic"]="https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/OpenDyslexic.zip"
  ["Hack"]="https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/Hack.zip"
  ["SourceCodePro"]="https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/SourceCodePro.zip"
)

echo "Starting Nerd Fonts installation from official repo..."

for font_name in "${!fonts_urls[@]}"; do
  url="${fonts_urls[$font_name]}"
  echo "Downloading $font_name..."
  curl -fLo "$TEMP_DIR/${font_name}.zip" "$url" || { echo "Failed to download $font_name"; continue; }
  echo "Extracting $font_name..."
  unzip -qq "$TEMP_DIR/${font_name}.zip" -d "$TEMP_DIR/$font_name"
  echo "Installing $font_name fonts..."
  find "$TEMP_DIR/$font_name" -type f \( -iname "*.ttf" -o -iname "*.otf" \) -exec mv -v {} "$FONT_DIR/" \;
done

rm -rf "$TEMP_DIR"

echo "Refreshing fonts cache..."
fc-cache -f -v "$FONT_DIR"

echo "Nerd Fonts installation complete."
