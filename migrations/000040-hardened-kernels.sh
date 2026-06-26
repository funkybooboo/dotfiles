# 000040-hardened-kernels.sh — hardened + LTS kernels
# Installs: linux-hardened linux-hardened-headers linux-lts linux-lts-headers
# Links:    —
# Enables:  —
# Note: To set the hardened kernel as the default boot entry, ensure the
#       `/Arch Linux (linux-hardened)` block is first in
#       /boot/limine/limine.conf (Limine boots the first entry by default).
#       This is a one-time manual setup step — migrations do not reorder boot
#       entries. Migration 000051-apparmor-cmdline.sh appends the AppArmor LSM
#       params to each existing entry but does not change their order.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "Hardened + LTS Kernels"

install_pacman \
  linux-hardened linux-hardened-headers \
  linux-lts linux-lts-headers
ok "hardened + LTS kernels"
