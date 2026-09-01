# 000400-power-management.sh -- power-profiles-daemon + brightnessctl + udev rule + battery notify
# Installs: power-profiles-daemon brightnessctl upower
# Removes:  swayosd (superseded -- see the group-membership note below)
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

# swayosd is superseded: volume and brightness state now render in the waybar
# pulseaudio/backlight modules instead of a floating OSD, and media-keys applies
# changes through wpctl/brightnessctl (swayosd 0.3.2 got brightness wrong on this
# backlight -- see media-keys). Removed here rather than in its own migration
# because this migration owns what replaced it, matching how 000204-podman
# removes docker.
remove_pkg swayosd

# `video` group membership is required to WRITE /sys/class/backlight/*/brightness;
# without it brightness changes fail silently. It used to be granted by the
# now-deleted 000314-swayosd, but brightness itself did not go away -- media-keys,
# hypridle's dim-on-idle, and the kbd-backlight binds all shell out to
# brightnessctl. So the membership lives here, with the migration that installs
# brightnessctl. Requires a logout/login (or newgrp/reboot) to take effect.
# The `input` group is not granted here. It existed only so swayosd's LibInput
# backend could read /dev/input/event* directly, and was dropped with swayosd --
# but it is granted again by 000325-espanso.sh, whose EVDEV backend reads typed
# triggers from those same devices. This migration is not its owner.
if groups "$USER" | grep -qw video; then
  skip "$USER already in video group"
elif sudo usermod -aG video "$USER"; then
  warn "added $USER to video group -- log out and back in for this to take effect"
  _add_warning "log out and back in for video group membership to take effect"
else
  warn "failed to add $USER to video group"
  _add_warning "usermod -aG video $USER failed; add manually: sudo usermod -aG video $USER"
fi

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
