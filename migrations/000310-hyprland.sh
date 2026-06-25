# 000310-hyprland.sh — Hyprland compositor + Wayland ecosystem + config + scripts
# Installs: hyprland hypridle hyprlock hyprpicker hyprsunset hyprpaper
#           hyprpolkitagent hyprlauncher cliphist uwsm wayfreeze
#           xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
#           xdg-desktop-portal-wlr qt5-wayland qt6-wayland resvg
# Links:    ~/.config/hypr/**, ~/.config/systemd/user/hypr-wallpaper.service,
#           ~/.local/bin/{hypr-keybinds,hypr-kill-workspace,hypr-lid-switch,
#             hypr-toggle-display,screenshot,screencast,recording-indicator,
#             toggle-lock,nightmode-toggle,theme-switch,clipboard-manager,
#             power-mode-menu}
# Enables:  hypr-wallpaper.service

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "hyprland"

install_pacman \
  hyprland hypridle hyprlock hyprpicker hyprsunset hyprpaper \
  hyprpolkitagent hyprlauncher cliphist wayfreeze \
  xdg-desktop-portal-hyprland xdg-desktop-portal-gtk xdg-desktop-portal-wlr \
  qt5-wayland qt6-wayland resvg
install_aur uwsm
ok "Hyprland ecosystem"

link_tree "$DOTFILES_HOME/.config/hypr" "$HOME/.config/hypr"

# hypr-wallpaper user service unit
link_file "$DOTFILES_HOME/.config/systemd/user/hypr-wallpaper.service" \
  "$HOME/.config/systemd/user/hypr-wallpaper.service"

# Hyprland helper scripts
for _script in hypr-keybinds hypr-kill-workspace hypr-lid-switch \
  hypr-toggle-display screenshot screencast recording-indicator \
  toggle-lock nightmode-toggle theme-switch clipboard-manager power-mode-menu; do
  link_file "$DOTFILES_HOME/.local/bin/$_script" "$HOME/.local/bin/$_script"
done

enable_user_service "hypr-wallpaper.service"
