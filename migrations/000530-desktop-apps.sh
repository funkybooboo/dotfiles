# 000530-desktop-apps.sh -- GUI desktop applications (no config needed)
# Installs (pacman): thunar evince gnome-calculator gnome-disk-utility
#                    gnome-keyring imagemagick libreoffice-fresh ghostscript
#                    impala blanket bluetui
# Installs (AUR):    signal-desktop losslesscut-bin cliamp lazyjournal-bin
#                    lazysql-bin
# Installs (Debian): thunar evince gnome-calculator gnome-disk-utility
#                    gnome-keyring imagemagick libreoffice ghostscript blanket
#                    signal-desktop (via pre-configured Signal apt repo)
# Links:    --
# Enables:  --

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "desktop apps"

if is_debian; then
  install_apt \
    thunar evince gnome-calculator gnome-disk-utility \
    gnome-keyring imagemagick libreoffice ghostscript blanket

  # signal-desktop: repo expected to be pre-configured (see repo setup)
  install_apt signal-desktop

  # These tools have no apt package; install via flatpak/cargo/release manually
  _add_warning "losslesscut: install via flatpak or release from https://github.com/mifi/lossless-cut/releases"
  _add_warning "cliamp: install via cargo ('cargo install cliamp') on Debian"
  _add_warning "lazyjournal: install via release from https://github.com/Lifailon/lazyjournal/releases"
  _add_warning "lazysql: install via release from https://github.com/jorgerojas26/lazysql/releases"
  _add_warning "impala: install via release from https://github.com/pythops/impala/releases"
  _add_warning "bluetui: install via release from https://github.com/pythops/bluetui/releases"
else
  install_pacman \
    thunar evince gnome-calculator gnome-disk-utility \
    gnome-keyring imagemagick libreoffice-fresh ghostscript \
    impala blanket bluetui

  install_aur \
    signal-desktop losslesscut-bin cliamp lazyjournal-bin lazysql-bin
fi

ok "desktop apps"
