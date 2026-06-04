# 08-hyprland.sh — Hyprland + Wayland ecosystem

section "Hyprland"

info "installing Hyprland and Wayland tools..."
run_cmd sudo pacman -S --needed --noconfirm \
  hyprland waybar mako hyprlock hypridle hyprpicker hyprsunset \
  swaybg grim slurp satty swayosd wl-clipboard wtype \
  xdg-desktop-portal-hyprland xdg-desktop-portal-gtk xdg-desktop-portal-wlr \
  qt5-wayland qt6-wayland \
  cliphist hyprpaper hyprpolkitagent hyprlauncher wf-recorder
run_cmd yay -S --needed --noconfirm \
  nwg-displays wayfreeze uwsm
[[ $DRY_RUN -eq 0 ]] && ok "Hyprland ecosystem"