#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# setup.sh — symlink your dotfiles and local binaries into $HOME
#            but abort on any conflict (no auto-removal)
# -----------------------------------------------------------------------------

DRY_RUN=0
FORCE=0

usage() {
  cat <<EOF
Usage: $0 [--dry-run|-n] [--force|-f]

  --dry-run, -n   Print the commands that would be run, but do not execute them.
  --force, -f     Remove existing files/symlinks before creating new ones.
  --help, -h      Show this help message.
EOF
  exit 1
}

# parse args
while [[ $# -gt 0 ]]; do
  case $1 in
  -n | --dry-run)
    DRY_RUN=1
    shift
    ;;
  -f | --force)
    FORCE=1
    shift
    ;;
  -h | --help) usage ;;
  *) usage ;;
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

# helper: ensure DEST does not exist (or remove it if --force)
check_conflict() {
  local dest="$1"
  if [[ -e "$dest" ]] || [[ -L "$dest" ]]; then
    if [[ $FORCE -eq 1 ]]; then
      echo "Removing existing: $dest"
      run_cmd rm -rf "$dest"
    else
      echo "conflict: '$dest' already exists. Use --force to overwrite or remove it manually."
      exit 1
    fi
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

# Optional: Set up ClamAV if installed
if command -v clamdscan &>/dev/null && command -v freshclam &>/dev/null; then
  echo ">>> Setting up ClamAV"
  run_cmd sudo systemctl stop clamav-freshclam || true
  run_cmd sudo systemctl stop clamav-daemon || true
  run_cmd sudo freshclam
  run_cmd sudo systemctl start clamav-daemon
  run_cmd sudo systemctl enable clamav-daemon
  run_cmd sudo systemctl start clamav-freshclam
  run_cmd sudo systemctl enable clamav-freshclam
  run_cmd clamdscan --version
  if [[ $DRY_RUN -eq 0 ]]; then
    echo "test" >/tmp/testfile
    run_cmd clamdscan /tmp/testfile
  fi
  run_cmd sudo setfacl -R -m u:clamav:rx /home/nate
else
  echo ">>> Skipping ClamAV setup (not installed)"
fi

echo ">>> Done${suffix}."
