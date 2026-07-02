# 000526-monero.sh -- Monero GUI wallet
# Installs: monero-gui
# Links:    --
# Enables:  --

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "monero"

if is_debian; then
  # monero CLI is in the Ubuntu universe repo (package: monero)
  install_apt monero
  # monero-gui is not in apt; use flatpak or the official release from getmonero.org
  _add_warning "monero-gui: install via flatpak or .tar.bz2 from https://getmonero.org/downloads/"
else
  install_pacman monero-gui
fi
