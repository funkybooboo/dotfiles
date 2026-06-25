# 000533-gnome-disk-utility.sh — GNOME Disks (disk management)
# Installs: gnome-disk-utility
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "gnome-disk-utility"

install_pacman gnome-disk-utility
