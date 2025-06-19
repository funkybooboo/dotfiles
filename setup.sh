#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# setup.sh — symlink your dotfiles, .scripts, wallpapers, and binaries into $HOME
#            but abort on any conflict (no auto-removal)
# -----------------------------------------------------------------------------

DRY_RUN=0

usage() {
  cat <<EOF
Usage: $0 [--dry-run|-n]

  --dry-run, -n   Print the commands that would be run, but do not execute them.
  --help, -h      Show this help message.
EOF
  exit 1
}

# parse args
while [[ $# -gt 0 ]]; do
  case $1 in
    -n|--dry-run) DRY_RUN=1; shift ;;
    -h|--help)    usage ;;
    *)            usage ;;
  esac
done

# helper: run or echo
run_cmd() {
  if [[ $DRY_RUN -eq 1 ]]; then
    echo "+ $*"
  else
    "$@"
  fi
}

# helper: ensure DEST does not exist
check_conflict() {
  local dest="$1"
  if [[ -e "$dest" ]]; then
    echo "⛔ conflict: '$dest' already exists.  Aborting."
    exit 1
  fi
}

# 1) cd into repo
cd "$(dirname "${BASH_SOURCE[0]}")"

# 2) need jq
if ! command -v jq &>/dev/null; then
  echo "Error: jq not installed."
  exit 1
fi

# 3) load binaries list
bins=( $(jq -r '.["add-to-path"][]' config.json) )

# 4) link each whole folder under config/.config → ~/.config/*
echo ">>> Linking full ~/.config sub-folders"
run_cmd mkdir -p "$HOME/.config"
for entry in config/.config/*; do
  dest="$HOME/.config/$(basename "$entry")"
  check_conflict "$dest"
  run_cmd ln -s "$PWD/$entry" "$dest"
done

# 5) link entire scripts/.scripts → ~/.scripts
echo ">>> Linking full ~/.scripts"
check_conflict "$HOME/.scripts"
run_cmd ln -s "$PWD/scripts/.scripts" "$HOME/.scripts"

# 6) per-file dotfiles from other pkgs → $HOME
pkgs=( bash gdbinit ideavim vim git alejandra )
echo ">>> Linking files into \$HOME"
for pkg in "${pkgs[@]}"; do
  while IFS= read -r src; do
    rel="${src#"$PWD/$pkg/"}"
    dest="$HOME/$rel"
    check_conflict "$dest"
    run_cmd mkdir -p "$(dirname "$dest")"
    run_cmd ln -s "$src" "$dest"
  done < <(find "$PWD/$pkg" -type f)
done

# 7) link binaries → ~/.local/bin
echo ">>> Linking into ~/.local/bin"
run_cmd mkdir -p "$HOME/.local/bin"
for rel in "${bins[@]}"; do
  src="$PWD/$rel"
  dest="$HOME/.local/bin/$(basename "$rel")"
  check_conflict "$dest"
  run_cmd ln -s "$src" "$dest"
done

# 8) link full wallpapers folder → ~/Pictures/wallpapers
echo ">>> Linking full wallpapers folder"
run_cmd mkdir -p "$HOME/Pictures"
dest="$HOME/Pictures/wallpapers"
check_conflict "$dest"
run_cmd ln -s "$PWD/Pictures/wallpapers" "$dest"

echo ">>> Done${DRY_RUN:+ (dry-run)}."
