#!/usr/bin/env bash
# Install ble.sh (Bash Line Editor) for Fish-like features

set -euo pipefail

echo "=== Installing ble.sh (Bash Line Editor) ==="

BLESH_DIR="$HOME/.local/share/blesh"

# Check if already installed
if [ -f "$BLESH_DIR/ble.sh" ]; then
  echo "ble.sh is already installed at $BLESH_DIR"
  echo "To update, run: bash $BLESH_DIR/ble.sh --update"
  exit 0
fi

# Create directory
mkdir -p "$HOME/.local/share"

# Clone ble.sh
echo "Cloning ble.sh repository..."
git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git "$BLESH_DIR"

# Build ble.sh
echo "Building ble.sh (this may take a minute)..."
cd "$BLESH_DIR"
make

echo ""
echo "✓ ble.sh installed successfully!"
echo ""
echo "Features enabled:"
echo "  - Fish-like autosuggestions (gray text from history)"
echo "  - Syntax highlighting (colors for commands)"
echo "  - Enhanced tab completion"
echo "  - Better history search"
echo ""
echo "Restart your shell or run: source ~/.bashrc"
echo ""
echo "Keybindings:"
echo "  - Right Arrow / Ctrl+F : Accept suggestion"
echo "  - Ctrl+R              : History search"
echo "  - Tab                 : Enhanced completion"
