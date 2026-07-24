# 000562-impala.sh -- impala (pacman)
# Installs: impala
# Links:    --
# Enables:  --
# Note: one piece of software = one migration. impala is the Arch official
#       build (extra/, GPG-signed). Split out of the former 000530-desktop-apps
#       grab-bag (the apps there are independent -- not related or dependent).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "impala"

install_pacman impala

ok "impala"
