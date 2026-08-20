# 000309-chromium.sh -- Chromium web browser (pacman; skipped on Debian) + chromium-flags.conf
# Installs: chromium
# Links:   ~/.config/chromium-flags.conf
# Enables: --
# Note: one piece of software = one migration. chromium-flags.conf lives here
#       because the flags only apply to chromium. The other browsers live in
#       000303-firefox, 000313-brave, 000307-librewolf, 000308-mullvad-browser.
#       Chromium is the Arch official build (extra/, GPG-signed).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "chromium"

if is_debian; then
  # Ubuntu's 'chromium-browser' is a transitional shim that installs the
  # Chromium SNAP and drags in snapd. Deliberately not doing that here --
  # the flags file below is still linked so a hand-installed chromium
  # picks it up.
  skip "chromium (Ubuntu ships only a snap shim)"
  _add_warning "chromium not installed on Ubuntu; use 'snap install chromium' if wanted"
else
  install_pacman chromium
fi
link_file "$DOTFILES_HOME/.config/chromium-flags.conf" "$HOME/.config/chromium-flags.conf"

ok "chromium"