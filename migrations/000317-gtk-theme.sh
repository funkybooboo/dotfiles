# 000317-gtk-theme.sh -- GTK 3/4 dark theme config + xsettingsd
# Installs: xsettingsd gnome-themes-extra
# Links:    ~/.config/gtk-3.0/settings.ini, ~/.config/gtk-4.0/settings.ini,
#           ~/.config/xsettingsd/xsettingsd.conf
# Enables:  --

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "gtk theme"

# gnome-themes-extra is what actually provides /usr/share/themes/Adwaita-dark.
# gtk3/gtk4 ship only the built-in Adwaita, so without this package the
# Adwaita-dark name in the settings.ini files below resolves to nothing, and
# env.lua's GTK2_RC_FILES / GTK3_RC_FILES point at files that do not exist.
install_pacman xsettingsd gnome-themes-extra
link_file "$DOTFILES_HOME/.config/gtk-3.0/settings.ini"        "$HOME/.config/gtk-3.0/settings.ini"
link_file "$DOTFILES_HOME/.config/gtk-4.0/settings.ini"        "$HOME/.config/gtk-4.0/settings.ini"
link_file "$DOTFILES_HOME/.config/xsettingsd/xsettingsd.conf"  "$HOME/.config/xsettingsd/xsettingsd.conf"
