# 000218-tree.sh — tree (recursive directory listing)
# Installs: tree
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "tree"

install_pacman tree
