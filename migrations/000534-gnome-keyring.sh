# 000534-gnome-keyring.sh — GNOME Keyring (secrets service)
# Installs: gnome-keyring
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "gnome-keyring"

install_pacman gnome-keyring
