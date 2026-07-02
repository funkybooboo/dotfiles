# 000401-bluetooth.sh -- bluez + bluez-utils + btusb modprobe config
# Installs: bluez bluez-utils
# Deploys: /etc/modprobe.d/btusb.conf
# Enables:  --

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "bluetooth"

if is_debian; then
  install_apt bluez
else
  install_pacman bluez bluez-utils
fi
deploy_etc_file "$DOTFILES_ROOT_ETC/modprobe.d/btusb.conf" \
  "/etc/modprobe.d/btusb.conf" 644
