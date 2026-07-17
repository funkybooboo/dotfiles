# 000530-desktop-apps.sh — GUI desktop applications (no config needed)
# Installs (pacman): thunar evince gnome-calculator gnome-disk-utility
#                    gnome-keyring imagemagick libreoffice-fresh ghostscript
#                    impala blanket bluetui
# Installs (AUR):     signal-desktop, losslesscut-bin
# Builds (local):    cliamp (go), lazyjournal (go), lazysql (go)
# Links:    —
# Enables:  —
# Note: losslesscut moved back to the AUR `losslesscut-bin` (an Electron app —
#       the flatpak sandbox is mostly redundant overhead here, and pacman-db
#       tracking of its .desktop + mimetype registration is cleaner). The
#       former flatpak `no.mifi.losslesscut` is uninstalled if present.
#       cliamp/lazyjournal/lazysql are built from upstream source via local
#       PKGBUILDs (pkgbuilds/); lazyjournal/lazysql replace= the former AUR
#       -bin packages (auto-removed on install). signal-desktop stays AUR-only
#       (not in the off-AUR scope). Debug symbol packages are swept by 000550.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "desktop apps"

install_pacman \
  thunar evince gnome-calculator gnome-disk-utility \
  gnome-keyring imagemagick libreoffice-fresh ghostscript \
  impala blanket bluetui

# signal-desktop remains AUR-only (not in the off-AUR scope; see project note).
install_aur signal-desktop

# losslesscut: AUR -bin (Electron app; flatpak sandbox redundant, pacman-db
# tracking the .desktop/mimetypes is the cleaner integration here). Uninstall
# the former flatpak build if present (--delete-data; the AUR build keeps none
# of the flatpak sandbox's per-app data by design).
install_aur losslesscut-bin
remove_flatpak no.mifi.losslesscut

# cliamp, lazyjournal, lazysql: build from upstream source (local PKGBUILDs).
# lazyjournal/lazysql local PKGBUILDs replace= the former -bin packages.
install_local_pkgbuild cliamp
install_local_pkgbuild lazyjournal
install_local_pkgbuild lazysql

ok "desktop apps"
