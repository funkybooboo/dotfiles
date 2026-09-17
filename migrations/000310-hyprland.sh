# 000310-hyprland.sh -- Hyprland compositor + Wayland ecosystem + config + scripts
# Installs: hyprland hypridle hyprlock hyprpicker hyprsunset
#           hyprpolkitagent cliphist uwsm
#           xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
#           xdg-desktop-portal-wlr qt5-wayland qt6-wayland resvg
# Nix:     .#wayfreeze
# Links:    ~/.config/hypr/**,
#           ~/.local/bin/{hypr-keybinds,hypr-kill-workspace,hypr-lid-switch,
#             hypr-toggle-display,hypr-ocr,screenshot,screencast,
#             toggle-lock,toggle-touchpad,nightmode-toggle,keepawake-toggle,
#             power-mode-menu,hypr-float-apply,hypr-float-launch,
#             hypr-float-toggle,power-menu}
# Enables:  --

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "hyprland"

install_pacman \
  hyprland hypridle hyprlock hyprpicker hyprsunset \
  hyprpolkitagent cliphist uwsm \
  xdg-desktop-portal-hyprland xdg-desktop-portal-gtk xdg-desktop-portal-wlr \
  qt5-wayland qt6-wayland resvg
# wayfreeze: installed from nixpkgs -- replaces the former pkgbuilds/ build.
install_nix .#wayfreeze
ok "Hyprland ecosystem"

link_tree "$DOTFILES_HOME/.config/hypr" "$HOME/.config/hypr"

# Hyprland helper scripts
for _script in hypr-keybinds hypr-kill-workspace hypr-lid-switch \
  hypr-toggle-display hypr-ocr screenshot screencast \
  toggle-lock toggle-touchpad nightmode-toggle \
  power-mode-menu hypr-float-apply hypr-float-launch \
  hypr-float-toggle \
  power-menu \
  keepawake-toggle; do
  link_file "$DOTFILES_HOME/.local/bin/$_script" "$HOME/.local/bin/$_script"
done

