# 000210-cli-utilities.sh — CLI utilities and dev tools (no config needed)
# Installs (pacman): fzf fd eza dust fastfetch jq wl-clipboard zoxide tree
#                    tealdeer unzip rsync ncdu inotify-tools ast-grep 7zip socat
# Installs (AUR):    gum tdf timg lazydocker act
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "CLI utilities"

install_pacman \
  fzf fd eza dust fastfetch jq wl-clipboard zoxide tree \
  tealdeer unzip rsync ncdu inotify-tools ast-grep 7zip socat

install_aur \
  gum tdf timg lazydocker act

ok "CLI utilities"
