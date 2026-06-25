# 000301-flatpak.sh — Flatpak + Flathub remote
# Installs: flatpak
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "flatpak"

install_pacman flatpak
run_cmd_retry 3 10 flatpak remote-add --if-not-exists flathub \
  https://flathub.org/repo/flathub.flatpakrepo
ok "flatpak + flathub remote"
