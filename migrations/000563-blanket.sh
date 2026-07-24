# 000563-blanket.sh -- blanket (pacman)
# Installs: blanket
# Links:    --
# Enables:  --
# Note: one piece of software = one migration. blanket is the Arch official
#       build (extra/, GPG-signed). Split out of the former 000530-desktop-apps
#       grab-bag (the apps there are independent -- not related or dependent).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "blanket"

install_pacman blanket

ok "blanket"
