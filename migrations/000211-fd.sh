# 000211-fd.sh — fd (find replacement)
# Installs: fd
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "fd"

install_pacman fd
