# 000500-calcure.sh -- calcure (TUI calendar) + config
# Installs: calcure
# Links:    ~/.config/calcure/config.ini
# Enables:  --
# Note: calendar-tui (in personal-admin-scripts) launches calcure.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "calcure"

if is_debian; then
  if ! command -v pipx &>/dev/null; then
    _add_warning "calcure: pipx not installed -- run 'pipx install calcure' manually"
  elif command -v calcure &>/dev/null; then
    skip "calcure (already installed via pipx)"
  else
    if pipx install calcure; then
      ok "calcure installed via pipx"
    else
      _add_warning "calcure: 'pipx install calcure' failed -- install manually"
    fi
  fi
else
  install_aur calcure
fi
link_file "$DOTFILES_HOME/.config/calcure/config.ini" "$HOME/.config/calcure/config.ini"
