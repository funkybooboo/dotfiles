# 000301-flatpak.sh — Flatpak + Flathub remote
# Installs: flatpak
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "flatpak"

install_pacman flatpak
if run_cmd_retry 3 10 flatpak remote-add --if-not-exists flathub \
  https://flathub.org/repo/flathub.flatpakrepo; then
  ok "flatpak + flathub remote"
else
  warn "failed to add flathub remote — flatpaks won't install until added manually"
  _add_warning "flathub remote-add failed; run 'flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo' manually"
fi
