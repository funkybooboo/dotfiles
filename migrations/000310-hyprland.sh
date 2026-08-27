# 000310-hyprland.sh -- Hyprland compositor + Wayland ecosystem + config + scripts
# Installs: hyprland hypridle hyprlock hyprpicker hyprsunset hyprpaper
#           hyprpolkitagent hyprlauncher cliphist uwsm
#           xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
#           xdg-desktop-portal-wlr qt5-wayland qt6-wayland resvg
# Nix:     .#wayfreeze
# Links:    ~/.config/hypr/**, ~/.config/hyprlauncher/hyprlauncher.conf,
#           ~/.config/systemd/user/hypr-wallpaper.service,
#           ~/.local/bin/{hypr-keybinds,hypr-kill-workspace,hypr-lid-switch,
#             hypr-toggle-display,screenshot,screencast,recording-indicator,
#             toggle-lock,nightmode-toggle,nightmode-indicator,theme-switch,
#             clipboard-manager,
#             power-mode-menu,hypr-float-apply,hypr-float-launch,
#             hypr-float-toggle,hypr-window-switcher,
#             hypr-window-switcher-inner,power-menu}
# Enables:  hypr-wallpaper.service

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "hyprland"

install_pacman \
  hyprland hypridle hyprlock hyprpicker hyprsunset hyprpaper \
  hyprpolkitagent hyprlauncher cliphist uwsm \
  xdg-desktop-portal-hyprland xdg-desktop-portal-gtk xdg-desktop-portal-wlr \
  qt5-wayland qt6-wayland resvg
# wayfreeze: installed from nixpkgs -- replaces the former pkgbuilds/ build.
install_nix .#wayfreeze
ok "Hyprland ecosystem"

link_tree "$DOTFILES_HOME/.config/hypr" "$HOME/.config/hypr"

# hypr-wallpaper user service unit
link_file "$DOTFILES_HOME/.config/systemd/user/hypr-wallpaper.service" \
  "$HOME/.config/systemd/user/hypr-wallpaper.service"

# Hyprland helper scripts
for _script in hypr-keybinds hypr-kill-workspace hypr-lid-switch \
  hypr-toggle-display screenshot screencast recording-indicator \
  toggle-lock nightmode-toggle nightmode-indicator theme-switch \
  clipboard-manager power-mode-menu hypr-float-apply hypr-float-launch \
  hypr-float-toggle hypr-window-switcher hypr-window-switcher-inner \
  power-menu media-keys; do
  link_file "$DOTFILES_HOME/.local/bin/$_script" "$HOME/.local/bin/$_script"
done

# hyprlauncher (application launcher) config -- enlarged window for readability.
link_file "$DOTFILES_HOME/.config/hyprlauncher/hyprlauncher.conf" \
  "$HOME/.config/hyprlauncher/hyprlauncher.conf"

enable_user_service "hypr-wallpaper.service"
