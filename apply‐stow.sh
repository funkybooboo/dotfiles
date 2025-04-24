#!/usr/bin/env bash
set -euo pipefail

# ——— CONFIGURATION ———
# Path to your dotfiles repo (default ~/dotfiles)
DOTDIR="${1:-$HOME/dotfiles}"
# Where to symlink (default your home)
TARGET="${2:-$HOME}"

cd "$DOTDIR" || { echo "❌ '$DOTDIR' not found"; exit 1; }

# List your packages here in the order you like:
PACKAGES=(bash config gdbinit ideavim scripts vim)

echo "👉  Stowing into: $TARGET"
for pkg in "${PACKAGES[@]}"; do
  if [[ -d "$pkg" ]]; then
    echo "  ↪️  [$pkg]"
    stow --restow -v -t "$TARGET" "$pkg"
  else
    echo "  ⚠️  Skipping '$pkg' (directory not found)"
  fi
done

echo "✅  All done! Your dotfiles are now linked."

