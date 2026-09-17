# 000083-android-udev.sh -- Android USB device udev rules + adbusers group
# Installs: android-udev (pulls libmtp)
# Enables:  $USER in adbusers
# Note: exists to flash GrapheneOS onto Pixel phones from this machine via
#       the official web installer (https://grapheneos.org/install/web) in
#       chromium (000309) or brave (000313): the rules give the browser's
#       WebUSB stack 0660 access to the fastboot device (18d1:4ee0), plus a
#       uaccess tag for the seated session, so adbusers membership is
#       belt-and-braces. The adb/fastboot CLIs ship separately in
#       android-tools, which is deliberately NOT installed -- the web
#       installer replaces them.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "android-udev"

install_pacman android-udev

# The package's sysusers hook creates the adbusers group at install time, so
# membership is only added after install_pacman has run.
if groups "$USER" | grep -qw adbusers; then
  skip "adbusers group (already a member)"
elif sudo usermod -aG adbusers "$USER"; then
  warn "added $USER to adbusers group -- log out and back in for this to take effect"
  _add_warning "log out and back in for adbusers group membership to take effect"
else
  warn "failed to add $USER to adbusers group"
  _add_warning "usermod -aG adbusers failed; add manually: sudo usermod -aG adbusers $USER"
fi

ok "android-udev"