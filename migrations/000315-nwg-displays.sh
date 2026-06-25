# 000315-nwg-displays.sh — nwg-displays (Wayland display/output manager)
# Installs: nwg-displays
# Links:    ~/.config/nwg-displays/config
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "nwg-displays"

install_aur nwg-displays
link_file "$DOTFILES_HOME/.config/nwg-displays/config" "$HOME/.config/nwg-displays/config"
