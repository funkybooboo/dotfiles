#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# setup.sh — symlink your dotfiles and local binaries into $HOME
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
    echo "conflict: '$dest' already exists. Aborting."
    exit 1
  fi
}

# 1) cd into repo root
cd "$(dirname "${BASH_SOURCE[0]}")"

# 2) link everything from home/.local/bin/* → ~/.local/bin/*
echo ">>> Linking executables into ~/.local/bin"
run_cmd mkdir -p "$HOME/.local/bin"
for entry in home/.local/bin/*; do
  dest="$HOME/.local/bin/$(basename "$entry")"
  check_conflict "$dest"
  run_cmd ln -s "$PWD/$entry" "$dest"
done

# 3) link each folder under home/.config → ~/.config/*
echo ">>> Linking config folders into ~/.config"
run_cmd mkdir -p "$HOME/.config"
for entry in home/.config/*; do
  dest="$HOME/.config/$(basename "$entry")"
  check_conflict "$dest"
  run_cmd ln -s "$PWD/$entry" "$dest"
done

# 4) link per-file dotfiles from home/* → $HOME (excluding .config and .local)
echo ">>> Linking dotfiles into \$HOME"
while IFS= read -r src; do
  rel="${src#"$PWD/home/"}"
  dest="$HOME/$rel"
  check_conflict "$dest"
  run_cmd mkdir -p "$(dirname "$dest")"
  run_cmd ln -s "$src" "$dest"
done < <(
  find "$PWD/home" -type f \
    ! -path "$PWD/home/.config/*" \
    ! -path "$PWD/home/.local/*"
)

suffix=""
if [[ $DRY_RUN -eq 1 ]]; then
  suffix=" (dry-run)"
fi

echo ">>> Done${suffix}."
