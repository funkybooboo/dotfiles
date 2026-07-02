# 000303-browsers.sh -- web browsers + chromium flags
# Installs: firefox chromium librewolf-bin brave-bin
# Links:    ~/.config/chromium-flags.conf
# Enables:  --

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "browsers"

if is_debian; then
  # brave-browser: add the official apt repo if not already present
  add_apt_repo \
    "https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg" \
    "/etc/apt/keyrings/brave-browser-archive-keyring.gpg" \
    "deb [signed-by=/etc/apt/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" \
    "brave-browser-release"
  install_apt brave-browser
  # librewolf: add the official deb.librewolf.net repo then install
  _lw_codename="$(lsb_release -cs 2>/dev/null || echo "noble")"
  add_apt_repo \
    "https://deb.librewolf.net/keyring.gpg" \
    "/usr/share/keyrings/librewolf.gpg" \
    "deb [arch=amd64 signed-by=/usr/share/keyrings/librewolf.gpg] https://deb.librewolf.net ${_lw_codename} main" \
    "librewolf"
  install_apt librewolf
  # firefox and chromium are snap packages on Ubuntu; install manually if needed
  info "firefox/chromium are snap packages on Ubuntu -- install via: snap install firefox chromium"
  _add_warning "firefox/chromium not installed; use snap: snap install firefox chromium"
else
  install_pacman firefox chromium
  install_aur librewolf-bin brave-bin
fi
link_file "$DOTFILES_HOME/.config/chromium-flags.conf" "$HOME/.config/chromium-flags.conf"
