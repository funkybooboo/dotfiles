# 000526-monero.sh — Monero GUI wallet
# Installs: monero-gui
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "monero"

install_pacman monero-gui
