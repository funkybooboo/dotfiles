# 000305-mpv.sh -- mpv media player + config + lazymusic player
# Installs: mpv
# Links:    ~/.config/mpv/input.conf,
#           ~/.local/share/applications/lazymusic.desktop,
#           ~/.local/bin/lazymusic -> sources/lazymusic/lazymusic (submodule)
# Enables:  --
# Note: lazymusic is consumed IN PLACE from the sources/lazymusic submodule
#       (initialized in preflight): the .desktop Exec path points into the
#       checkout, and a user-level symlink at ~/.local/bin/lazymusic provides
#       the terminal command -- no build, no copy, no sudo. The retired
#       setup.sh rebuild loop also `sudo make install`ed a root-owned copy to
#       /usr/local/bin; the sweep below removes that fossil via the Makefile's
#       own uninstall target. If the submodule is not populated the .desktop
#       is still linked and will work once the submodule is initialized.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "mpv"

install_pacman mpv
link_file "$DOTFILES_HOME/.config/mpv/input.conf" "$HOME/.config/mpv/input.conf"
link_file "$DOTFILES_HOME/.local/share/applications/lazymusic.desktop" \
  "$HOME/.local/share/applications/lazymusic.desktop"

# lazymusic is consumed IN PLACE from the sources/lazymusic submodule
# (initialized in preflight). Non-fatal, but the .desktop entry will not
# launch without it.
if source_ready lazymusic; then
  ok "lazymusic source (submodule sources/lazymusic)"
  # Terminal command: a symlink into the checkout, not a copy -- exactly one
  # live copy of the player, fresh the moment setup.sh rolls the pointer.
  link_file "$REPO_ROOT/sources/lazymusic/lazymusic" "$HOME/.local/bin/lazymusic"
fi

# --- fossil sweep ---------------------------------------------------------------
# The retired setup.sh rebuild loop `sudo make install`ed a root-owned copy at
# /usr/local/bin/lazymusic -- a second copy, behind sudo, drifting from the
# checkout. Remove it once via the Makefile's own uninstall target. Existence-
# guarded so every later run is a clean sudo-free skip; a failed sweep warns.
if [[ -f /usr/local/bin/lazymusic ]]; then
  if sudo make -C "$REPO_ROOT/sources/lazymusic" uninstall; then
    ok "swept fossil /usr/local/bin/lazymusic (retired setup.sh install)"
  else
    warn "could not sweep /usr/local/bin/lazymusic"
    _add_warning "lazymusic: /usr/local/bin fossil still present"
  fi
else
  skip "lazymusic /usr/local fossil (absent)"
fi
