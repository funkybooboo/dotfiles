# 000409-fwupd.sh — fwupd (firmware update daemon)
# Installs: fwupd
# Links:    —
# Enables:  — (fwupd is invoked on-demand via fwupdmgr)

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "fwupd"

install_pacman fwupd
