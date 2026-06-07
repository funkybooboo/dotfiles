# 08-hyprland-wayland.sh — Hyprland + Wayland ecosystem

section "Hyprland"

info "installing Hyprland and Wayland tools..."
install_pacman \
  hyprland waybar mako hyprlock hypridle hyprpicker hyprsunset \
  swaybg grim slurp satty swayosd wl-clipboard wtype \
  xdg-desktop-portal-hyprland xdg-desktop-portal-gtk xdg-desktop-portal-wlr \
  qt5-wayland qt6-wayland \
  cliphist hyprpaper hyprpolkitagent hyprlauncher wf-recorder
install_aur nwg-displays wayfreeze uwsm
[[ $DRY_RUN -eq 0 ]] && ok "Hyprland ecosystem" || true