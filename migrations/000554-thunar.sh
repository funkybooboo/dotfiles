# 000554-thunar.sh -- thunar (pacman)
# Installs: thunar
# Links:    --
# Enables:  --
# Note: one piece of software = one migration. thunar is the Arch official
#       build (extra/, GPG-signed). Split out of the former 000530-desktop-apps
#       grab-bag (the apps there are independent -- not related or dependent).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "thunar"

install_pacman thunar

ok "thunar"
