# 000530-desktop-apps.sh — GUI desktop applications (no config needed)
# Installs (pacman): thunar evince gnome-calculator gnome-disk-utility
#                    gnome-keyring imagemagick libreoffice-fresh ghostscript
#                    impala blanket bluetui signal-desktop
# Nix:               .#losslesscut .#cliamp .#lazyjournal .#lazysql
# Links:   —
# Enables: —
# Note: losslesscut moved off flatpak to nix (Electron app; flatpak sandbox
#       redundant). The former flatpak build is uninstalled on first run.
#       signal-desktop is in extra/ (official Arch).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "desktop apps"

install_pacman \
  thunar evince gnome-calculator gnome-disk-utility \
  gnome-keyring imagemagick libreoffice-fresh ghostscript \
  impala blanket bluetui

# signal-desktop is in extra/ (Arch-maintained).
install_pacman signal-desktop

# losslesscut: from nix (Electron app; flatpak sandbox redundant).
# The former flatpak build is uninstalled on first run.
install_nix .#losslesscut
remove_flatpak no.mifi.losslesscut

# cliamp, lazyjournal, lazysql: from nix.
install_nix .#cliamp
install_nix .#lazyjournal
install_nix .#lazysql

ok "desktop apps"
