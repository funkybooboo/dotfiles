# 000319-xdg.sh — XDG user dirs + environment variables + mime apps
# Installs: xdg-user-dirs
# Links:    ~/.config/environment.d/apps.conf, ~/.config/user-dirs.dirs,
#           ~/.config/mimeapps.list
# Creates: The XDG user directories declared in user-dirs.dirs
# Enables:  —
#
# xdg-user-dirs ships xdg-user-dirs-update, but we do NOT run it: it rewrites
# user-dirs.dirs to match its locale-based defaults, which would clobber the
# symlinked config (and the custom Projects dir). Instead we create the
# directories directly from the config — idempotent, respects the user's
# declared paths, and never touches the config file.
#
# The NAS sync dirs (Photos, Audiobooks, Books) are NOT XDG dirs and are not
# declared in user-dirs.dirs; setup.sh creates those during the
# initial NAS clone.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "xdg"

install_pacman xdg-user-dirs
link_file "$DOTFILES_HOME/.config/environment.d/apps.conf" "$HOME/.config/environment.d/apps.conf"
link_file "$DOTFILES_HOME/.config/user-dirs.dirs"          "$HOME/.config/user-dirs.dirs"
link_file "$DOTFILES_HOME/.config/mimeapps.list"           "$HOME/.config/mimeapps.list"

# Create the directories declared in user-dirs.dirs. We source the config
# (it's valid shell: XDG_xxx_DIR="$HOME/yyy") and mkdir -p each value. This
# is idempotent and never overwrites existing dirs.
_user_dirs_conf="$HOME/.config/user-dirs.dirs"
if [[ -f "$_user_dirs_conf" ]]; then
  _created=0
  while IFS='=' read -r _key _val; do
    # Skip comments / blank lines / non-XDG lines
    [[ "$_key" =~ ^[[:space:]]*XDG_ ]] || continue
    # Strip surrounding quotes and whitespace from the value
    _val="${_val#\"}"; _val="${_val%\"}"
    _val="${_val//\$HOME/$HOME}"
    _val="${_val//\$XDG_/_invalid_}"  # no nested XDG vars; skip if present
    [[ "$_val" == *_invalid_* ]] && continue
    if [[ -n "$_val" && ! -d "$_val" ]]; then
      mkdir -p "$_val"
      _created=$((_created + 1))
    fi
  done < "$_user_dirs_conf"
  if (( _created > 0 )); then
    ok "created $_created XDG user directory/directories"
  else
    skip "XDG user directories already present"
  fi
else
  warn "$_user_dirs_conf not found — cannot create XDG dirs"
  _add_warning "user-dirs.dirs missing; XDG directories not created"
fi
