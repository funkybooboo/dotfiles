# 000538-impala.sh — Impala (TUI database client)
# Installs: impala
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "impala"

install_pacman impala
