# 000520-proton-vpn.sh -- Proton VPN CLI + GUI + vpn wrapper script
# Installs: proton-vpn-cli proton-vpn-gtk-app (both in extra/ -- official Arch)
# Links:    ~/.local/bin/vpn
# Enables:  --

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "proton vpn"

if is_debian; then
  # Ubuntu packages the GTK app (which pulls the CLI in as a dependency);
  # there is no separate proton-vpn-cli package.
  install_apt proton-vpn-gtk-app
else
  install_pacman proton-vpn-cli proton-vpn-gtk-app
fi
link_file "$DOTFILES_HOME/.local/bin/vpn" "$HOME/.local/bin/vpn"
