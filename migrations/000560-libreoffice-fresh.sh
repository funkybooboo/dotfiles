# 000560-libreoffice-fresh.sh -- libreoffice-fresh (pacman)
# Installs: libreoffice-fresh
# Links:    --
# Enables:  --
# Note: one piece of software = one migration. libreoffice-fresh is the Arch official
#       build (extra/, GPG-signed). Split out of the former 000530-desktop-apps
#       grab-bag (the apps there are independent -- not related or dependent).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "libreoffice-fresh"

install_pacman libreoffice-fresh

ok "libreoffice-fresh"
