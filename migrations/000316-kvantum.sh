# 000316-kvantum.sh -- Kvantum Qt theme engine + config
# Installs: kvantum kvantum-qt5
# Links:    ~/.config/Kvantum/kvantum.kvconfig
# Enables:  --

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "kvantum"

# Arch splits Kvantum by Qt major: `kvantum` links qt6-base, `kvantum-qt5`
# links qt5-base. QT_STYLE_OVERRIDE=kvantum (set in hypr/env.lua) is a silent
# no-op for a Qt5 app when only the Qt6 plugin is installed, which leaves
# openscad -- the one Qt5 app here -- on Qt5's default light palette.
install_pacman kvantum kvantum-qt5
link_file "$DOTFILES_HOME/.config/Kvantum/kvantum.kvconfig" \
  "$HOME/.config/Kvantum/kvantum.kvconfig"
