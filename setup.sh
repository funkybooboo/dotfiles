#!/usr/bin/env bash
set -euo pipefail
shopt -s dotglob nullglob

# ——— PARSE ARGS ———
DRYRUN=0
if [[ "${1:-}" == "--dry-run" ]]; then
  DRYRUN=1
  shift
fi

DOTDIR="${1:-$HOME/dotfiles}"
TARGET_HOME="${2:-$HOME}"
TS=$(date +'%Y%m%d%H%M%S%N')           # nanosecond timestamp for backups
BACKUP_DIR="$DOTDIR/stow-backups/$TS"

# ——— 0) PROMPT FOR SUDO (once) ———
if (( DRYRUN )); then
  echo "DRY RUN: would request sudo credentials now"
else
  echo "🔒 This script needs sudo to handle /etc. Please enter your password when prompted."
  sudo -v
  ( while true; do sudo -n true; sleep 60; done ) &
  SUDO_PID=$!
  trap 'kill $SUDO_PID' EXIT
fi

# ——— helper to run or echo ———
run() {
  if (( DRYRUN )); then
    echo "DRY RUN: $*"
  else
    eval "$*"
  fi
}

cd "$DOTDIR" || { echo "❌ dotfiles repo not found at $DOTDIR"; exit 1; }

# ——— prepare backup dirs ———
if (( DRYRUN )); then
  echo "DRY RUN: mkdir -p $BACKUP_DIR/home $BACKUP_DIR/root"
else
  mkdir -p "$BACKUP_DIR/home" "$BACKUP_DIR/root"
  echo "📦 Backups will go into: $BACKUP_DIR"
fi

# ——— helper for backups ———
backup_path() {
  src="$1"; dest="$2"
  if (( DRYRUN )); then
    echo "DRY RUN: mkdir -p $(dirname "$dest")"
    echo "DRY RUN: mv $src $dest  # or cp+rm on cross-FS"
  else
    mkdir -p "$(dirname "$dest")"
    if ! mv "$src" "$dest" 2>/dev/null; then
      cp -a "$src" "$dest"
      rm -rf "$src"
    fi
  fi
}

# ——— 1) BACKUP CONFLICTS: HOME PACKAGES ———
HOME_PKGS=(bash config gdbinit ideavim scripts vim)
echo "🔍 Checking home-package conflicts…"
for pkg in "${HOME_PKGS[@]}"; do
  [[ -d $pkg ]] || continue

  # dir-vs-file (a file where a directory should go)
  find "$pkg" -type d | while read -r d; do
    rel=${d#"$pkg"/}; tgt="$TARGET_HOME/$rel"
    if [[ -f $tgt && ! -d $tgt ]]; then
      echo "  • backing up file blocking dir: $tgt"
      backup_path "$tgt" "$BACKUP_DIR/home/$rel"
    fi
  done

  # file-vs-file and symlinks
  find "$pkg" -type f -o -type l | while read -r f; do
    rel=${f#"$pkg"/}; tgt="$TARGET_HOME/$rel"
    if [[ -e $tgt || -L $tgt ]]; then
      echo "  • backing up existing path: $tgt"
      backup_path "$tgt" "$BACKUP_DIR/home/$rel"
    fi
  done
done

# ——— 2) BACKUP CONFLICTS: SYSTEM PACKAGE (etc/) ———
if [[ -d etc ]]; then
  echo "🔍 Checking system-package conflicts…"
  # dir-vs-file under /etc
  find etc -type d | while read -r d; do
    rel=${d#etc/}; tgt="/$rel"
    if [[ -f $tgt && ! -d $tgt ]]; then
      echo "  • backing up root file blocking dir: $tgt"
      if (( DRYRUN )); then
        echo "DRY RUN: sudo mkdir -p $BACKUP_DIR/root/$(dirname "$rel")"
        echo "DRY RUN: sudo mv $tgt $BACKUP_DIR/root/$rel"
      else
        sudo mkdir -p "$BACKUP_DIR/root/$(dirname "$rel")"
        if ! sudo mv "$tgt" "$BACKUP_DIR/root/$rel" 2>/dev/null; then
          sudo cp -a "$tgt" "$BACKUP_DIR/root/$rel"
          sudo rm -rf "$tgt"
        fi
      fi
    fi
  done
  # file-vs-file and symlinks under /etc
  find etc -type f -o -type l | while read -r f; do
    rel=${f#etc/}; tgt="/$rel"
    if [[ -e $tgt || -L $tgt ]]; then
      echo "  • backing up existing root path: $tgt"
      if (( DRYRUN )); then
        echo "DRY RUN: sudo mkdir -p $BACKUP_DIR/root/$(dirname "$rel")"
        echo "DRY RUN: sudo mv $tgt $BACKUP_DIR/root/$rel"
      else
        sudo mkdir -p "$BACKUP_DIR/root/$(dirname "$rel")"
        if ! sudo mv "$tgt" "$BACKUP_DIR/root/$rel" 2>/dev/null; then
          sudo cp -a "$tgt" "$BACKUP_DIR/root/$rel"
          sudo rm -rf "$tgt"
        fi
      fi
    fi
  done
fi

echo "✅ Backups complete."

# ——— 3) REMOVE STALE ABSOLUTE SYMLINKS ———
echo "🗑 Removing stale home-package symlinks…"
for pkg in bash gdbinit ideavim vim; do
  [[ -d $pkg ]] || continue
  for src in "$pkg"/*; do
    base=${src##*/}; tgt="$TARGET_HOME/$base"
    if [[ -L $tgt ]]; then
      run rm "$tgt"
      echo "  • removed $tgt"
    fi
  done
done

# ——— 4) STOW HOME PACKAGES ———
echo "👉  Stowing home-package symlinks into $TARGET_HOME"
STOW_HOME_ARGS=(--restow -d "$DOTDIR" -t "$TARGET_HOME" "${HOME_PKGS[@]}")
if (( DRYRUN )); then
  stow -n -v "${STOW_HOME_ARGS[@]}"
else
  stow -v "${STOW_HOME_ARGS[@]}"
fi

# ——— 5) STOW NIXOS CONFIG ———
if [[ -d etc/nixos ]]; then
  echo "👉  Stowing NixOS configuration into /etc"
  STOW_SYS_ARGS=(--restow -d "$DOTDIR/etc" -t /etc nixos)
  if (( DRYRUN )); then
    sudo stow -n -v "${STOW_SYS_ARGS[@]}"
  else
    sudo stow -v "${STOW_SYS_ARGS[@]}"
  fi
else
  echo "⚠️  etc/nixos not found; skipping system config"
fi

# ——— 6) REGISTER SCRIPTS INTO PATH ———
BIN_DIR="$TARGET_HOME/.local/bin"
run mkdir -p "$BIN_DIR"

if [[ -f config.json ]]; then
  echo "🔗 Registering scripts into $BIN_DIR"
  while IFS= read -r rel; do
    [[ -z $rel ]] && continue
    src="$DOTDIR/$rel"
    link="$BIN_DIR/$(basename "$rel")"
    if [[ -f $src ]]; then
      run ln -sf "$src" "$link"
    else
      echo "  ⚠️  $rel not found, skipping"
    fi
  done < <(jq -r '.["add-to-path"][]' "$DOTDIR/config.json")
else
  echo "⚠️  config.json missing; skipping path registration"
fi

echo -e "✅ All done!
• Home dotfiles → $TARGET_HOME
• NixOS config → /etc/nixos
• Backups → $BACKUP_DIR
• Scripts in PATH → $BIN_DIR"

