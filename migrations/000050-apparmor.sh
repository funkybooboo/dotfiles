# 000050-apparmor.sh — AppArmor + profiles + service
# Installs: apparmor, apparmor.d (local PKGBUILD, GPG-verified upstream tarball)
# Links:    —
# Enables:  apparmor.service
# Note: apparmor.d is built from the upstream release tarball
#       (github.com/roddhjav/apparmor.d) via a local PKGBUILD in pkgbuilds/ —
#       no yay/AUR at runtime. The source tarball is GPG-signed; the signing
#       key is imported below so makepkg verifies the .asc (safe-source:
#       signature verification kept ON, not skipped).
#       The AppArmor LSM parameters are added to the kernel cmdline in
#       /boot/limine/limine.conf by the follow-up migration 000051-apparmor-
#       cmdline.sh. A reboot is required for AppArmor to become active.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "AppArmor"

install_pacman apparmor
# Import the apparmor.d upstream signing key (idempotent) so makepkg can
# verify the release tarball signature. Key FP from the project's README.
gpg --recv-keys 06A26D531D56C42D66805049C5469996F0DF68EC 2>/dev/null || \
  warn "could not import apparmor.d signing key — makepkg sig check may fail"
install_local_pkgbuild apparmor.d
ok "AppArmor + profiles"

# AppArmor cannot actually run until the LSM parameters below are added to
# the kernel cmdline and the system is rebooted. Enable WITHOUT starting so
# the "enabled" line isn't misleading — the service stays inactive until that
# reboot (you may also see a benign "apparmor.service is not active, cannot
# reload" error from the apparmor.d post-transaction hook until then).
enable_system_service_no_start "apparmor.service"

# The cmdline edit is handled by 000051-apparmor-cmdline.sh, which runs next.
# No hand-editing required.
