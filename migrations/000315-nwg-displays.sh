# 000315-nwg-displays.sh -- nwg-displays (Wayland display/output manager)
# Installs: nwg-displays (now in extra/ -- official Arch package)
# Links:    ~/.config/nwg-displays/config
# Enables:  --

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "nwg-displays"

if is_debian; then
  install_apt nwg-displays
else
  install_pacman nwg-displays
fi
link_file "$DOTFILES_HOME/.config/nwg-displays/config" "$HOME/.config/nwg-displays/config"
