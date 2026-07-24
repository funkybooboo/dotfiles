# 000558-gnome-keyring.sh -- gnome-keyring (pacman)
# Installs: gnome-keyring
# Links:    --
# Enables:  --
# Note: one piece of software = one migration. gnome-keyring is the Arch official
#       build (extra/, GPG-signed). Split out of the former 000530-desktop-apps
#       grab-bag (the apps there are independent -- not related or dependent).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "gnome-keyring"

install_pacman gnome-keyring

ok "gnome-keyring"
