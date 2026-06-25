# 000319-xdg.sh — XDG user dirs + environment variables + mime apps
# Installs: xdg-user-dirs
# Links:    ~/.config/environment.d/apps.conf, ~/.config/user-dirs.dirs,
#           ~/.config/mimeapps.list
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "xdg"

install_pacman xdg-user-dirs
link_file "$DOTFILES_HOME/.config/environment.d/apps.conf" "$HOME/.config/environment.d/apps.conf"
link_file "$DOTFILES_HOME/.config/user-dirs.dirs"          "$HOME/.config/user-dirs.dirs"
link_file "$DOTFILES_HOME/.config/mimeapps.list"           "$HOME/.config/mimeapps.list"
