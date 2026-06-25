# 000030-fstab.sh — deploy /etc/fstab (machine-specific)
# Installs: —
# Deploys: /etc/fstab
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "fstab"

deploy_etc_file "$DOTFILES_ROOT_ETC/fstab" "/etc/fstab" 644
warn "/etc/fstab deployed — verify mounts with 'findmnt' before rebooting"
