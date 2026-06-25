# 000225-7zip.sh — 7zip (archive tool)
# Installs: 7zip
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "7zip"

install_pacman 7zip
