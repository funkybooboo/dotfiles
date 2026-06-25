# 000314-swayosd.sh — swayosd (on-screen display for brightness/volume)
# Installs: swayosd
# Links:    ~/.config/swayosd/style.css
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "swayosd"

install_pacman swayosd
link_file "$DOTFILES_HOME/.config/swayosd/style.css" "$HOME/.config/swayosd/style.css"
