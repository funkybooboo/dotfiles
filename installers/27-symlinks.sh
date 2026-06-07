# 27-symlinks.sh — create symlinks for dotfiles

section "Symlinking Dotfiles"

info "~/.local/bin (scripts)"
link_tree "$DOTFILES_HOME/.local/bin" "$HOME/.local/bin"

if [[ -d "$DOTFILES_HOME/.local/lib" ]]; then
  info "~/.local/lib (libraries)"
  link_tree "$DOTFILES_HOME/.local/lib" "$HOME/.local/lib"
fi

if [[ -d "$DOTFILES_HOME/.local/share" ]]; then
  info "~/.local/share"
  link_tree "$DOTFILES_HOME/.local/share" "$HOME/.local/share"
fi

info "~/.config"
link_tree "$DOTFILES_HOME/.config" "$HOME/.config" "opencode"

info "~/.config/opencode (directory symlink)"
link_dir "$DOTFILES_HOME/.config/opencode" "$HOME/.config/opencode"

info "\$HOME dotfiles (.gitconfig, .vimrc, .ssh/config, …)"
while IFS= read -r src; do
  rel="${src#"$DOTFILES_HOME/"}"
  dest="$HOME/$rel"
  if _resolve_conflict "$dest" "$src"; then
    if [[ $DRY_RUN -eq 1 ]]; then
      echo -e "  ${DIM}+ ln -s $src $dest${NC}"
    else
      mkdir -p "$(dirname "$dest")"
      ln -s "$src" "$dest"
    fi
  fi
done < <(find "$DOTFILES_HOME" -type f \
  ! -path "$DOTFILES_HOME/.config/*" \
  ! -path "$DOTFILES_HOME/.local/*")