# 000314-swayosd.sh — swayosd (on-screen display for brightness/volume)
# Installs: swayosd
# Links:    ~/.config/swayosd/style.css
# Enables:  —
# Note: Adds $USER to the `video` group (required to WRITE /sys/class/backlight/
#       */brightness, which swayosd's udev rule 99-swayosd.rules chgrps to video --
#       without this, brightness changes silently fail) and the `input` group
#       (so swayosd's LibInput backend can read /dev/input/event* natively). Both
#       require a logout/login (or `newgrp`/reboot) to take effect.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "swayosd"

install_pacman swayosd
link_file "$DOTFILES_HOME/.config/swayosd/style.css" "$HOME/.config/swayosd/style.css"

# Group memberships required for swayosd brightness + native input handling.
# `video`: needed to write /sys/class/backlight/*/brightness (udev rule 99-swayosd.rules
#   does `chgrp video ... ; chmod g+w`, so membership is mandatory for backlight writes).
# `input`: lets swayosd's LibInput backend read /dev/input/event* directly (otherwise it
#   logs "LibInput Backend isn't available" and falls back to compositor-forwarded keys).
for _grp in video input; do
  if groups "$USER" | grep -qw "$_grp"; then
    skip "$USER already in $_grp group"
  elif sudo usermod -aG "$_grp" "$USER"; then
    warn "added $USER to $_grp group -- log out and back in for this to take effect"
    _add_warning "log out and back in for $_grp group membership to take effect"
  else
    warn "failed to add $USER to $_grp group"
    _add_warning "usermod -aG $_grp $USER failed; add manually: sudo usermod -aG $_grp $USER"
  fi
done
