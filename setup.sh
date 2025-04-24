#!/usr/bin/env bash
set -euo pipefail

# ─── Locate this script and cd into its directory ──────────────────────────────
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

# ─── Check for GNU stow ─────────────────────────────────────────────────────────
if ! command -v stow &>/dev/null; then
  echo "❌  GNU stow not found. Install it (e.g. 'sudo apt install stow') and re-run."
  exit 1
fi

# ─── Gather packages (everything except etc, .git, setup.sh, README/Licenses) ────
PACKAGES=()
for entry in * .[!.]*; do
  case "$entry" in
    .|..|.git|setup.sh|etc|README.md|LICENSE|*.un~) continue ;;
  esac
  PACKAGES+=("$entry")
done

# ─── Stow into $HOME, force-overwriting any existing files/links ───────────────
echo "🔗  Stowing to \$HOME (overwriting conflicts): ${PACKAGES[*]}"
for pkg in "${PACKAGES[@]}"; do
  stow \
    --verbose \
    --target="$HOME" \
    --restow \
    --override='*' \
    "$pkg"
done

# ─── Stow etc into /etc, also force-overwriting ────────────────────────────────
echo "🔗  Stowing 'etc' to /etc (requires sudo, overwriting conflicts)"
sudo stow \
  --verbose \
  --target=/etc \
  --restow \
  --override='*' \
  etc

echo "✅  All done!"

