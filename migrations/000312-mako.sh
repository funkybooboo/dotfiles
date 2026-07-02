# 000312-mako.sh -- mako notification daemon
# Installs: mako
# Links:    ~/.config/mako/config
# Enables:  --

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "mako"

if is_debian; then
  # Package is mako-notifier on Debian/Ubuntu; the binary is still named mako
  install_apt mako-notifier
else
  install_pacman mako
fi
link_file "$DOTFILES_HOME/.config/mako/config" "$HOME/.config/mako/config"
