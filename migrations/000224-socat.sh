# 000224-socat.sh -- socat (pacman / apt)
# Installs: socat
# Links:    --
# Enables:  --
# Note: one piece of software = one migration. socat is the Arch official
#       build (extra/, GPG-signed). Split out of the former 000210-cli-utilities
#       grab-bag (the apps there are independent -- not related or dependent).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "socat"

if is_debian; then
  install_apt socat
else
  install_pacman socat
fi

ok "socat"
