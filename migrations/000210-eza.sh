# 000210-eza.sh -- eza (pacman / apt)
# Installs: eza
# Links:    --
# Enables:  --
# Note: one piece of software = one migration. eza is the Arch official
#       build (extra/, GPG-signed). Split out of the former 000210-cli-utilities
#       grab-bag (the apps there are independent -- not related or dependent).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "eza"

if is_debian; then
  install_apt eza
else
  install_pacman eza
fi

ok "eza"
