# 000302-ghostty.sh -- Ghostty terminal emulator
# Installs: ghostty (now in extra/ -- official Arch package)
# Links:    ~/.config/ghostty/config
# Enables:  --

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "ghostty"

if is_debian; then
  # ghostty landed in the Ubuntu archive (resolute/universe), so the
  # community .deb fetch this branch originally used is no longer needed.
  install_apt ghostty
else
  install_pacman ghostty
fi
link_file "$DOTFILES_HOME/.config/ghostty/config" "$HOME/.config/ghostty/config"
