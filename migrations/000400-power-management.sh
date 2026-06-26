# 000400-power-management.sh — power-profiles-daemon + udev rule + battery notify
# Installs: power-profiles-daemon brightnessctl
# Links:    ~/.config/systemd/user/power-profile-switch.service,
#           ~/.config/systemd/user/battery-notify.service,
#           ~/.config/systemd/user/battery-notify.timer,
#           ~/.local/bin/power-mode-menu,
#           ~/.local/lib/power-profile-switch,
#           ~/.local/lib/battery-notify
# Deploys: /etc/udev/rules.d/99-power-profile.rules
# Enables:  power-profiles-daemon.service, power-profile-switch.service,
#           battery-notify.timer

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "power management"

install_pacman power-profiles-daemon brightnessctl upower

# udev rule switches power profile on AC/battery
deploy_etc_file "$DOTFILES_ROOT_ETC/udev/rules.d/99-power-profile.rules" \
  "/etc/udev/rules.d/99-power-profile.rules" 644
if command -v udevadm &>/dev/null; then
  sudo udevadm control --reload-rules 2>/dev/null || true
  sudo udevadm trigger --subsystem-match=power_supply 2>/dev/null || true
fi

# User services + helper scripts
link_file "$DOTFILES_HOME/.config/systemd/user/power-profile-switch.service" \
  "$HOME/.config/systemd/user/power-profile-switch.service"
link_file "$DOTFILES_HOME/.config/systemd/user/battery-notify.service" \
  "$HOME/.config/systemd/user/battery-notify.service"
link_file "$DOTFILES_HOME/.config/systemd/user/battery-notify.timer" \
  "$HOME/.config/systemd/user/battery-notify.timer"
link_file "$DOTFILES_HOME/.local/bin/power-mode-menu" \
  "$HOME/.local/bin/power-mode-menu"
link_file "$DOTFILES_HOME/.local/lib/power-profile-switch" \
  "$HOME/.local/lib/power-profile-switch"
link_file "$DOTFILES_HOME/.local/lib/battery-notify" \
  "$HOME/.local/lib/battery-notify"

enable_system_service "power-profiles-daemon.service"
# upower provides battery state over D-Bus (used by wireplumber for battery
# percentage, waybar, and battery-notify). It can start via D-Bus activation,
# but enabling it makes it reliably present at boot instead of depending on a
# caller to activate it.
enable_system_service "upower.service"
enable_user_service   "power-profile-switch.service"
enable_user_service   "battery-notify.timer"
