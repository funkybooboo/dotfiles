# 000311-waybar.sh -- Waybar status bar
# Installs: waybar
# Links:    ~/.config/waybar/**
# Enables:  --

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "waybar"

if is_debian; then
  install_apt waybar
else
  install_pacman waybar
fi
link_tree "$DOTFILES_HOME/.config/waybar" "$HOME/.config/waybar"
