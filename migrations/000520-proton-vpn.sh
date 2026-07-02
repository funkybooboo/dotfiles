# 000520-proton-vpn.sh -- Proton VPN CLI + GUI + vpn wrapper script
# Installs: proton-vpn-cli proton-vpn-gtk-app
# Links:    ~/.local/bin/vpn
# Enables:  --

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "proton vpn"

if is_debian; then
  # Proton VPN requires their own apt repository. Adding it automatically
  # requires knowing the exact current key URL and sources-list line, which
  # may change between releases. Add the repo manually, then re-run, or use
  # the .deb installer from https://repo.protonvpn.com.
  _add_warning "proton-vpn: add repo.protonvpn.com manually then run 'sudo apt-get install proton-vpn-gnome-desktop'"
else
  install_aur proton-vpn-cli proton-vpn-gtk-app
fi
link_file "$DOTFILES_HOME/.local/bin/vpn" "$HOME/.local/bin/vpn"
