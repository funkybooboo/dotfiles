# 000224-ast-grep.sh — ast-grep (structural search/rewrite tool)
# Installs: ast-grep
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "ast-grep"

install_pacman ast-grep
