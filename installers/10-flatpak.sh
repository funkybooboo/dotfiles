# 10-flatpak.sh — Flatpak + Flathub

section "Flatpak"

info "installing flatpak..."
run_cmd sudo pacman -S --needed --noconfirm flatpak
run_cmd flatpak remote-add --if-not-exists flathub \
  https://flathub.org/repo/flathub.flatpakrepo
[[ $DRY_RUN -eq 0 ]] && ok "flatpak + flathub remote"