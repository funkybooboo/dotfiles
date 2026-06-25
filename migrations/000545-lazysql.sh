# 000545-lazysql.sh — lazysql (TUI SQL client)
# Installs: lazysql-bin
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "lazysql"

install_aur lazysql-bin
