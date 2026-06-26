# 000050-apparmor.sh — AppArmor + profiles + service
# Installs: apparmor apparmor.d
# Links:    —
# Enables:  apparmor.service
# Note: The AppArmor LSM parameters are added to the kernel cmdline in
#       /boot/limine/limine.conf by the follow-up migration 000051-apparmor-
#       cmdline.sh. A reboot is required for AppArmor to become active.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "AppArmor"

install_pacman apparmor
install_aur apparmor.d
ok "AppArmor + profiles"

# AppArmor cannot actually run until the LSM parameters below are added to
# the kernel cmdline and the system is rebooted. Enable WITHOUT starting so
# the "enabled" line isn't misleading — the service stays inactive until that
# reboot (you may also see a benign "apparmor.service is not active, cannot
# reload" error from the apparmor.d post-transaction hook until then).
enable_system_service_no_start "apparmor.service"

# The cmdline edit is handled by 000051-apparmor-cmdline.sh, which runs next.
# No hand-editing required.
