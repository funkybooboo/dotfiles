# 000314-swayosd.sh -- swayosd (on-screen display for brightness/volume)
# Installs: swayosd
# Links:    ~/.config/swayosd/style.css
# Enables:  --

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "swayosd"

if is_debian; then
  install_apt swayosd
else
  install_pacman swayosd
fi
link_file "$DOTFILES_HOME/.config/swayosd/style.css" "$HOME/.config/swayosd/style.css"
