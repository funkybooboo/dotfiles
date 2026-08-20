# 000214-wl-clipboard.sh -- wl-clipboard (pacman / apt)
# Installs: wl-clipboard
# Links:    --
# Enables:  --
# Note: one piece of software = one migration. wl-clipboard is the Arch official
#       build (extra/, GPG-signed). Split out of the former 000210-cli-utilities
#       grab-bag (the apps there are independent -- not related or dependent).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "wl-clipboard"

if is_debian; then
  install_apt wl-clipboard
else
  install_pacman wl-clipboard
fi

ok "wl-clipboard"
