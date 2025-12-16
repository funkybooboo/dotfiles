#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# setup.sh — symlink your dotfiles and local binaries into $HOME
#            but abort on any conflict (no auto-removal)
# -----------------------------------------------------------------------------

DRY_RUN=0
FORCE=0
BACKUP=0

usage() {
  cat <<EOF
Usage: $0 [--dry-run|-n] [--force|-f] [--backup|-b]

  --dry-run, -n   Print the commands that would be run, but do not execute them.
  --force, -f     Remove existing files/symlinks before creating new ones.
  --backup, -b    Backup existing files/symlinks by renaming them with .bak suffix.
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
  -b | --backup)
    BACKUP=1
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

# helper: ensure DEST does not exist (or backup/remove it if --backup/--force)
check_conflict() {
  local dest="$1"
  if [[ -e "$dest" ]] || [[ -L "$dest" ]]; then
    if [[ $BACKUP -eq 1 ]]; then
      local backup_dest="${dest}.bak"
      # If .bak already exists, add a number
      local counter=1
      while [[ -e "$backup_dest" ]]; do
        backup_dest="${dest}.bak.${counter}"
        ((counter++))
      done
      echo "Backing up existing: $dest → $backup_dest"
      run_cmd mv "$dest" "$backup_dest"
    elif [[ $FORCE -eq 1 ]]; then
      echo "Removing existing: $dest"
      run_cmd rm -rf "$dest"
    else
      echo "conflict: '$dest' already exists. Use --backup to backup or --force to overwrite."
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

# Set up NAS sync
echo ">>> Setting up NAS sync"
run_cmd mkdir -p "$HOME/.config/nas-sync"

PASSWORD_FILE="$HOME/.config/nas-sync/rsync-password"
if [[ ! -f "$PASSWORD_FILE" ]] && [[ $DRY_RUN -eq 0 ]]; then
  echo ""
  echo "⚠️  NAS rsync password file not found."
  echo "Please enter your NAS rsync password (or press Enter to skip):"
  read -s -r nas_password
  if [[ -n "$nas_password" ]]; then
    echo "$nas_password" > "$PASSWORD_FILE"
    chmod 600 "$PASSWORD_FILE"
    echo "✓ Password file created at $PASSWORD_FILE"
  else
    echo "⚠️  Skipping password setup. Create it later with:"
    echo "   echo 'your_password' > $PASSWORD_FILE && chmod 600 $PASSWORD_FILE"
  fi
elif [[ -f "$PASSWORD_FILE" ]]; then
  echo "✓ Password file already exists"
fi

# Reload systemd and enable NAS sync timers
if [[ $DRY_RUN -eq 0 ]]; then
  echo ">>> Enabling NAS sync timers"
  systemctl --user daemon-reload

  for sync_type in documents music photos audiobooks; do
    systemctl --user enable "nas-sync-${sync_type}.timer"
    systemctl --user start "nas-sync-${sync_type}.timer"
  done

  echo "✓ NAS sync timers enabled and started"
  echo ""
  echo "Check timer status with: systemctl --user list-timers"
  echo "View sync logs with: journalctl --user -u nas-sync-documents.service -f"
else
  echo "+ systemctl --user daemon-reload"
  echo "+ systemctl --user enable nas-sync-documents.timer"
  echo "+ systemctl --user start nas-sync-documents.timer"
  echo "+ systemctl --user enable nas-sync-music.timer"
  echo "+ systemctl --user start nas-sync-music.timer"
  echo "+ systemctl --user enable nas-sync-photos.timer"
  echo "+ systemctl --user start nas-sync-photos.timer"
  echo "+ systemctl --user enable nas-sync-audiobooks.timer"
  echo "+ systemctl --user start nas-sync-audiobooks.timer"
fi

echo ">>> Done${suffix}."
