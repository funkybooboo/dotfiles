# 000532-gnome-calculator.sh — GNOME Calculator
# Installs: gnome-calculator
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "gnome-calculator"

install_pacman gnome-calculator
