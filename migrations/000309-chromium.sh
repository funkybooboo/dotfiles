# 000309-chromium.sh -- Chromium web browser (pacman) + chromium-flags.conf
# Installs: chromium
# Links:   ~/.config/chromium-flags.conf
# Enables: --
# Note: one piece of software = one migration. chromium-flags.conf lives here
#       because the flags only apply to chromium. The other browsers live in
#       000303-firefox, 000313-brave, 000307-librewolf, 000308-mullvad-browser.
#       Chromium is the Arch official build (extra/, GPG-signed).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "chromium"

install_pacman chromium
link_file "$DOTFILES_HOME/.config/chromium-flags.conf" "$HOME/.config/chromium-flags.conf"

ok "chromium"