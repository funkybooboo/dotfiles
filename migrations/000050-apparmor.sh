# 000050-apparmor.sh — AppArmor + profiles + service
# Installs: apparmor (pacman), apparmor.d stays as-is if already installed
# (the third-party profile collection by roddhjav is NOT in nixpkgs; it stays
# as the existing pacman-installed package from the former pkgbuilds/ — if it
# was never installed on a fresh machine, the stock apparmor profiles from
# pacman are sufficient).
# Links:    —
# Enables:  apparmor.service
# Note: The third-party apparmor.d profile collection (by roddhjav) is NOT
#       in nixpkgs and not in Arch official repos. The existing pacman-
#       installed package (from the former pkgbuilds/) stays if already
#       present; on a fresh machine, the stock apparmor profiles from the
#       pacman package are sufficient.
#       The AppArmor LSM parameters are added to the kernel cmdline in
#       /boot/limine/limine.conf by the follow-up migration 000051-apparmor-
#       cmdline.sh. A reboot is required for AppArmor to become active.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "AppArmor"

install_pacman apparmor
ok "AppArmor + profiles"

# AppArmor cannot actually run until the LSM parameters below are added to
# the kernel cmdline and the system is rebooted. Enable WITHOUT starting so
# the "enabled" line isn't misleading — the service stays inactive until that
# reboot (you may also see a benign "apparmor.service is not active, cannot
# reload" error from the apparmor.d post-transaction hook until then).
enable_system_service_no_start "apparmor.service"

# The cmdline edit is handled by 000051-apparmor-cmdline.sh, which runs next.
# No hand-editing required.
