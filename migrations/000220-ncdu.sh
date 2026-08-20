# 000220-ncdu.sh -- ncdu (pacman / apt)
# Installs: ncdu
# Links:    --
# Enables:  --
# Note: one piece of software = one migration. ncdu is the Arch official
#       build (extra/, GPG-signed). Split out of the former 000210-cli-utilities
#       grab-bag (the apps there are independent -- not related or dependent).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "ncdu"

if is_debian; then
  install_apt ncdu
else
  install_pacman ncdu
fi

ok "ncdu"
