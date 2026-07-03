# 000530-desktop-apps.sh — GUI desktop applications (no config needed)
# Installs (pacman): thunar evince gnome-calculator gnome-disk-utility
#                    gnome-keyring imagemagick libreoffice-fresh ghostscript
#                    impala blanket bluetui
# Flatpak:           no.mifi.losslesscut (officially maintained by upstream dev)
# Builds (local):    cliamp (go), lazyjournal (go), lazysql (go)
# Installs (AUR):    signal-desktop (not in scope — remains AUR-only)
# Links:    —
# Enables:  —
# Note: losslesscut comes from Flathub; cliamp/lazyjournal/lazysql are built
#       from upstream source via local PKGBUILDs (pkgbuilds/). lazyjournal
#       and lazysql local PKGBUILDs replace= the former AUR -bin packages
#       (auto-removed on install). signal-desktop stays AUR-only for now.
#       Debug symbol packages are swept by 000550-cleanup-aur-debug.sh.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "desktop apps"

install_pacman \
  thunar evince gnome-calculator gnome-disk-utility \
  gnome-keyring imagemagick libreoffice-fresh ghostscript \
  impala blanket bluetui

# signal-desktop remains AUR-only (not in the off-AUR scope; see project note).
install_aur signal-desktop

# losslesscut: official Flathub build (maintained by mifi, the upstream dev).
install_flatpak no.mifi.losslesscut
remove_pkg losslesscut-bin

# cliamp, lazyjournal, lazysql: build from upstream source (local PKGBUILDs).
# lazyjournal/lazysql local PKGBUILDs replace= the former -bin packages.
install_local_pkgbuild cliamp
install_local_pkgbuild lazyjournal
install_local_pkgbuild lazysql

ok "desktop apps"
