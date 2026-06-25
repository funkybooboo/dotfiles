# 000530-desktop-apps.sh — GUI desktop applications (no config needed)
# Installs (pacman): thunar evince gnome-calculator gnome-disk-utility
#                    gnome-keyring imagemagick libreoffice-fresh ghostscript
#                    impala blanket bluetui
# Installs (AUR):    signal-desktop losslesscut-bin cliamp lazyjournal-bin
#                    lazysql-bin
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "desktop apps"

install_pacman \
  thunar evince gnome-calculator gnome-disk-utility \
  gnome-keyring imagemagick libreoffice-fresh ghostscript \
  impala blanket bluetui

install_aur \
  signal-desktop losslesscut-bin cliamp lazyjournal-bin lazysql-bin

ok "desktop apps"
