# 000312-mako.sh — mako notification daemon
# Installs: mako
# Links:    ~/.config/mako/config
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "mako"

install_pacman mako
link_file "$DOTFILES_HOME/.config/mako/config" "$HOME/.config/mako/config"
