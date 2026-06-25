# 000535-imagemagick.sh — ImageMagick (image manipulation)
# Installs: imagemagick
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "imagemagick"

install_pacman imagemagick
