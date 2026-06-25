# 000317-gtk-theme.sh — GTK 3/4 dark theme config + xsettingsd
# Installs: xsettingsd
# Links:    ~/.config/gtk-3.0/settings.ini, ~/.config/gtk-4.0/settings.ini,
#           ~/.config/xsettingsd/xsettingsd.conf
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "gtk theme"

install_pacman xsettingsd
link_file "$DOTFILES_HOME/.config/gtk-3.0/settings.ini"        "$HOME/.config/gtk-3.0/settings.ini"
link_file "$DOTFILES_HOME/.config/gtk-4.0/settings.ini"        "$HOME/.config/gtk-4.0/settings.ini"
link_file "$DOTFILES_HOME/.config/xsettingsd/xsettingsd.conf"  "$HOME/.config/xsettingsd/xsettingsd.conf"
