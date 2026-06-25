# 000010-base.sh — Arch base system packages
# Installs: base base-devel curl wget lvm2 dmidecode linux-headers linux-firmware intel-ucode
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "Base System"

install_pacman \
  base base-devel curl wget lvm2 dmidecode \
  linux-headers linux-firmware intel-ucode
ok "base system"
