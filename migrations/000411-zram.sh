# 000411-zram.sh — zram-generator (compressed swap in RAM)
# Installs: zram-generator
# Links:    —
# Enables:  systemd-zram-setup@zram0.service (auto-started by udev on boot)

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "zram"

install_aur zram-generator
