# 000020-bootloader.sh — Limine bootloader + efibootmgr
# Installs: limine efibootmgr
# Links:    —
# Enables:  —
# Note: Installs the stock extra/limine package (UKI-based boot). The AUR
#       limine-mkinitcpio-hook / limine-snapper-sync packages are intentionally
#       NOT installed — they target a different config layout
#       (/etc/default/limine) than this machine uses (/boot/limine/limine.conf).
#       The boot config (/boot/limine/limine.conf) is NOT created or reordered
#       by migrations — that is a one-time manual setup step. Migration
#       000051-apparmor-cmdline.sh does append the AppArmor LSM params to each
#       existing `cmdline:` entry, but does not add/reorder entries.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "Bootloader (Limine)"

install_pacman limine efibootmgr
ok "Limine bootloader"
