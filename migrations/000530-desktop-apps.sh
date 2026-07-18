# 000530-desktop-apps.sh — GUI desktop applications (no config needed)
# Installs (pacman): thunar evince gnome-calculator gnome-disk-utility
#                    gnome-keyring imagemagick libreoffice-fresh ghostscript
#                    impala blanket bluetui signal-desktop
# Builds (local):    cliamp (go), lazyjournal (go), lazysql (go), losslesscut-bin
# Links:    —
# Enables:  —
# Note: losslesscut moved off flatpak to an audited local PKGBUILD
#       (pkgbuilds/losslesscut/, sha-pinned upstream tarball from
#       github.com/mifi/lossless-cut, see its AUDIT.md). It's an Electron app
#       so the flatpak sandbox was redundant; pacman-db .desktop/mimetype
#       integration is the cleaner tier here. cliamp/lazyjournal/lazysql are
#       likewise built from upstream source via local PKGBUILDs, lazyjournal/
#       lazysql replace= the former AUR -bin packages (auto-removed on install).
#       signal-desktop is now in extra/ (official Arch). Debug symbol packages
#       swept by 000550.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "desktop apps"

install_pacman \
  thunar evince gnome-calculator gnome-disk-utility \
  gnome-keyring imagemagick libreoffice-fresh ghostscript \
  impala blanket bluetui

# signal-desktop is now in extra/ (Arch-maintained).
install_pacman signal-desktop

# losslesscut: audited local PKGBUILD (Electron app; flatpak sandbox redundant,
# pacman-db .desktop/mimetype tracking is the cleaner integration here). The
# former flatpak build is uninstalled on first run.
install_nix nixpkgs#losslesscut
remove_flatpak no.mifi.losslesscut

# cliamp, lazyjournal, lazysql: build from upstream source (local PKGBUILDs).
# lazyjournal/lazysql local PKGBUILDs replace= the former -bin packages.
install_nix nixpkgs#cliamp
install_nix nixpkgs#lazyjournal
install_nix nixpkgs#lazysql

ok "desktop apps"
