# 000530-desktop-apps.sh — GUI desktop applications (no config needed)
# Installs (pacman): thunar evince gnome-calculator gnome-disk-utility
#                    gnome-keyring imagemagick libreoffice-fresh ghostscript
#                    impala blanket bluetui signal-desktop
# Installs (AUR):     losslesscut-bin (POLICY-HOLDOUT — see note)
# Builds (local):    cliamp (go), lazyjournal (go), lazysql (go)
# Links:    —
# Enables:  —
# Note: losslesscut moved off flatpak to AUR `losslesscut-bin` (Electron app —
#       flatpak sandbox redundant, pacman-db .desktop/mimetype integration is
#       cleaner here). It stays `install_aur` pending an in-tree
#       pkgbuilds/losslesscut/ + AUDIT.md migration (one of two remaining
#       install_aur holdouts after the 2026-07 off-AUR audit; calcure is the
#       other per its documented policy-exception note). Until that lands,
#       yay builds the AUR package from github.com/mifi/lossless-cut releases.
#       cliamp/lazyjournal/lazysql are built from upstream source via local
#       PKGBUILDs (pkgbuilds/); lazyjournal/lazysql replace= the former AUR
#       -bin packages (auto-removed on install). signal-desktop is now in
#       extra/ (official Arch). Debug symbol packages swept by 000550.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "desktop apps"

install_pacman \
  thunar evince gnome-calculator gnome-disk-utility \
  gnome-keyring imagemagick libreoffice-fresh ghostscript \
  impala blanket bluetui

# signal-desktop is now in extra/ (Arch-maintained).
install_pacman signal-desktop

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
