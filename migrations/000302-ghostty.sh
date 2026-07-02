# 000302-ghostty.sh -- Ghostty terminal emulator
# Installs: ghostty
# Links:    ~/.config/ghostty/config
# Enables:  --

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "ghostty"

if is_debian; then
  # Ghostty is not in apt; use the mkasberg/ghostty-ubuntu community .deb.
  # Dynamically fetch the asset URL for this Ubuntu version (idempotent: skips if ghostty present).
  _gty_ver="$(awk -F'"' '/^VERSION_ID=/{print $2; exit}' /etc/os-release 2>/dev/null)"
  _gty_url="$(curl -fsSL \
    "https://api.github.com/repos/mkasberg/ghostty-ubuntu/releases/latest" \
    2>/dev/null \
    | grep -o '"browser_download_url": *"[^"]*"' \
    | cut -d'"' -f4 \
    | grep -E "amd64_${_gty_ver}\.deb$" \
    | head -1)"
  if [[ -n "$_gty_url" ]]; then
    install_deb_url ghostty "$_gty_url" ghostty
  else
    warn "ghostty community .deb not found for Ubuntu ${_gty_ver:-unknown}"
    _add_warning "ghostty: install via snap or build on Debian"
  fi
else
  install_aur ghostty
fi
link_file "$DOTFILES_HOME/.config/ghostty/config" "$HOME/.config/ghostty/config"
