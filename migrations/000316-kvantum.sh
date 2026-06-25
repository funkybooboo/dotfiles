# 000316-kvantum.sh — Kvantum Qt theme engine + config
# Installs: kvantum
# Links:    ~/.config/Kvantum/kvantum.kvconfig
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "kvantum"

install_pacman kvantum
link_file "$DOTFILES_HOME/.config/Kvantum/kvantum.kvconfig" \
  "$HOME/.config/Kvantum/kvantum.kvconfig"
