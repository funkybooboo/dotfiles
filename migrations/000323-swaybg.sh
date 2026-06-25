# 000323-swaybg.sh — swaybg (Wayland wallpaper)
# Installs: swaybg
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "swaybg"

install_pacman swaybg
