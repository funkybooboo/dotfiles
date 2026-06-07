# 10-flatpak.sh — Flatpak + Flathub

section "Flatpak"

info "installing flatpak..."
install_pacman flatpak
run_cmd_retry 3 10 flatpak remote-add --if-not-exists flathub \
  https://flathub.org/repo/flathub.flatpakrepo
[[ $DRY_RUN -eq 0 ]] && ok "flatpak + flathub remote" || true