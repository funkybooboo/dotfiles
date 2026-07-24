# 000215-zoxide.sh -- zoxide (pacman)
# Installs: zoxide
# Links:    --
# Enables:  --
# Note: one piece of software = one migration. zoxide is the Arch official
#       build (extra/, GPG-signed). Split out of the former 000210-cli-utilities
#       grab-bag (the apps there are independent -- not related or dependent).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "zoxide"

install_pacman zoxide

ok "zoxide"
