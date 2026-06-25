# 000032-mkinitcpio.sh — deploy /etc/mkinitcpio.conf (machine-specific)
# Installs: —
# Deploys: /etc/mkinitcpio.conf
# Enables:  —
# Note: The config takes effect when kernels are installed/reinstalled next
#       (their pacman hooks run mkinitcpio). To apply to already-installed
#       kernels, run: sudo mkinitcpio -P

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "mkinitcpio"

deploy_etc_file "$DOTFILES_ROOT_ETC/mkinitcpio.conf" "/etc/mkinitcpio.conf" 644
warn "run 'sudo mkinitcpio -P' to regenerate initramfs for installed kernels"
_add_warning "run 'sudo mkinitcpio -P' to regenerate initramfs after mkinitcpio.conf change"
