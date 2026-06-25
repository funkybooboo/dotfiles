# 000020-bootloader.sh — Limine bootloader + snapper sync hook
# Installs: limine limine-mkinitcpio-hook limine-snapper-sync efibootmgr
# Links:    —
# Enables:  —
# Note: Must run BEFORE hardened-kernels and apparmor, which edit
#       /etc/default/limine (BOOT_ORDER + LSM params).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "Bootloader (Limine)"

install_pacman efibootmgr
install_aur limine limine-mkinitcpio-hook limine-snapper-sync
ok "Limine bootloader"
