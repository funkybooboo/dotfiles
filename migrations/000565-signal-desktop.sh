# 000565-signal-desktop.sh -- signal-desktop (pacman)
# Installs: signal-desktop
# Links:    --
# Enables:  --
# Note: one piece of software = one migration. signal-desktop is the Arch official
#       build (extra/, GPG-signed). Split out of the former 000530-desktop-apps
#       grab-bag (the apps there are independent -- not related or dependent).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "signal-desktop"

install_pacman signal-desktop

ok "signal-desktop"
