# 000040-hardened-kernels.sh — hardened + LTS kernels
# Installs: linux-hardened linux-hardened-headers linux-lts linux-lts-headers
# Links:    —
# Enables:  —
# Note: The Limine boot config (/boot/limine/limine.conf) is NOT edited by
#       migrations — boot configs are too critical for automated sed edits.
#       To set the hardened kernel as the default boot entry, edit
#       /boot/limine/limine.conf by hand and reorder the entries so
#       linux-hardened is first.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "Hardened + LTS Kernels"

install_pacman \
  linux-hardened linux-hardened-headers \
  linux-lts linux-lts-headers
ok "hardened + LTS kernels"
