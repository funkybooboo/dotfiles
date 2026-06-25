# 000216-wl-clipboard.sh — wl-clipboard (Wayland clipboard utilities)
# Installs: wl-clipboard
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "wl-clipboard"

install_pacman wl-clipboard
