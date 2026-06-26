# 000210-cli-utilities.sh — CLI utilities and dev tools (no config needed)
# Installs (pacman): fzf fd eza dust fastfetch jq wl-clipboard zoxide tree
#                    tealdeer unzip rsync ncdu inotify-tools ast-grep 7zip socat
#                    pandoc-cli (build dep for timg's manpage)
# Installs (AUR):    gum tdf timg lazydocker act
# Links:    —
# Enables:  —
# Note: pandoc-cli is installed BEFORE the AUR batch so that timg's PKGBUILD
#       can regenerate its manpage at build time. It is a somewhat heavy
#       (Haskell) dependency pulled in solely for that manpage.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "CLI utilities"

install_pacman \
  fzf fd eza dust fastfetch jq wl-clipboard zoxide tree \
  tealdeer unzip rsync ncdu inotify-tools ast-grep 7zip socat \
  pandoc-cli

install_aur \
  gum tdf timg lazydocker act

ok "CLI utilities"
