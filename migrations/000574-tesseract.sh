# 000574-tesseract.sh -- tesseract OCR engine (pacman)
# Installs: tesseract tesseract-data-eng
# Links:    --
# Enables:  --
# Note: one piece of software = one migration. The English traineddata is a
#       separate package from the engine, and tesseract cannot recognise anything
#       without it. Drives hypr-ocr (linked by 000310).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "tesseract"

install_pacman tesseract tesseract-data-eng

ok "tesseract"
