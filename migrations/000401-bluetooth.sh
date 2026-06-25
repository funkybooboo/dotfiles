# 000401-bluetooth.sh — bluez + bluez-utils + btusb modprobe config
# Installs: bluez bluez-utils
# Deploys: /etc/modprobe.d/btusb.conf
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "bluetooth"

install_pacman bluez bluez-utils
deploy_etc_file "$DOTFILES_ROOT_ETC/modprobe.d/btusb.conf" \
  "/etc/modprobe.d/btusb.conf" 644
