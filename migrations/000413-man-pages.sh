# 000413-man-pages.sh — man-db + less (manual page reading)
# Installs: man-db less
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "man pages"

install_pacman man-db less
