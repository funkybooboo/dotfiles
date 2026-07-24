# 000557-gnome-disk-utility.sh -- gnome-disk-utility (pacman)
# Installs: gnome-disk-utility
# Links:    --
# Enables:  --
# Note: one piece of software = one migration. gnome-disk-utility is the Arch official
#       build (extra/, GPG-signed). Split out of the former 000530-desktop-apps
#       grab-bag (the apps there are independent -- not related or dependent).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "gnome-disk-utility"

install_pacman gnome-disk-utility

ok "gnome-disk-utility"
