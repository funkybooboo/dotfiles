# 000303-browsers.sh — web browsers + chromium flags
# Installs: firefox chromium librewolf-bin brave-bin
# Links:    ~/.config/chromium-flags.conf
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "browsers"

install_pacman firefox chromium
install_aur librewolf-bin brave-bin
link_file "$DOTFILES_HOME/.config/chromium-flags.conf" "$HOME/.config/chromium-flags.conf"
