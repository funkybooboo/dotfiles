# 000537-ghostscript.sh — Ghostscript (PDF/PostScript interpreter)
# Installs: ghostscript
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "ghostscript"

install_pacman ghostscript
