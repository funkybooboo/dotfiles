# 000408-system-utilities.sh -- system service & maintenance utilities
# Installs (pacman): earlyoom fwupd yazi man-db less zram-generator
# Installs (apt):    earlyoom fwupd man-db less systemd-zram-generator
#                    (+ yazi from its upstream release -- not in apt)
# Links:    --
# Enables:  earlyoom.service (started -- safe, won't disrupt the session)
# Note: fwupd is on-demand via fwupdmgr (used by the update-firmware admin
#       script). zram-generator auto-starts via udev on boot. yazi is a
#       terminal file manager. man-db+less provide man pages.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "system utilities"

if is_debian; then
  # Renamed: zram-generator -> systemd-zram-generator. yazi is not in apt;
  # take the upstream release binary (tier 2).
  install_apt earlyoom fwupd man-db less systemd-zram-generator
  install_gh_release sxyazi/yazi 'x86_64-unknown-linux-gnu' yazi
else
  install_pacman earlyoom fwupd yazi man-db less zram-generator
fi

enable_system_service "earlyoom.service"

ok "system utilities"
