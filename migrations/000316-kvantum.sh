# 000316-kvantum.sh -- Kvantum Qt theme engine + config
# Installs: kvantum
# Links:    ~/.config/Kvantum/kvantum.kvconfig
# Enables:  --

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "kvantum"

if is_debian; then
  install_apt kvantum qt5-style-kvantum
else
  install_pacman kvantum
fi
link_file "$DOTFILES_HOME/.config/Kvantum/kvantum.kvconfig" \
  "$HOME/.config/Kvantum/kvantum.kvconfig"
