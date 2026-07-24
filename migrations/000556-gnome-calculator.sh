# 000556-gnome-calculator.sh -- gnome-calculator (pacman)
# Installs: gnome-calculator
# Links:    --
# Enables:  --
# Note: one piece of software = one migration. gnome-calculator is the Arch official
#       build (extra/, GPG-signed). Split out of the former 000530-desktop-apps
#       grab-bag (the apps there are independent -- not related or dependent).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "gnome-calculator"

install_pacman gnome-calculator

ok "gnome-calculator"
