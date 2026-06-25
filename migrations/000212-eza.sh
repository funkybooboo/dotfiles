# 000212-eza.sh — eza (ls replacement)
# Installs: eza
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "eza"

install_pacman eza
