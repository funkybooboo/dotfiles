# 000223-7zip.sh -- 7zip (pacman)
# Installs: 7zip
# Links:    --
# Enables:  --
# Note: one piece of software = one migration. 7zip is the Arch official
#       build (extra/, GPG-signed). Split out of the former 000210-cli-utilities
#       grab-bag (the apps there are independent -- not related or dependent).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "7zip"

install_pacman 7zip

ok "7zip"
