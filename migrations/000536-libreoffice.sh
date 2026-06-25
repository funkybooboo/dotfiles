# 000536-libreoffice.sh — LibreOffice (office suite)
# Installs: libreoffice-fresh
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "libreoffice"

install_pacman libreoffice-fresh
