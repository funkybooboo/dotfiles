# 000210-fzf.sh — fzf (fuzzy finder)
# Installs: fzf
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "fzf"

install_pacman fzf
