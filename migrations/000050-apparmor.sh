# 000050-apparmor.sh — AppArmor + profiles + service
# Installs: apparmor apparmor.d
# Links:    —
# Enables:  apparmor.service
# Note: The AppArmor LSM parameters must be added to the kernel cmdline by hand
#       in /boot/limine/limine.conf. Migrations do not edit the boot config
#       (too critical for automated sed edits). Add this to each entry's
#       cmdline: line:
#
#         lsm=landlock,lockdown,yama,integrity,apparmor,bpf
#
#       A reboot is required for AppArmor to become active after adding them.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "AppArmor"

install_pacman apparmor
install_aur apparmor.d
ok "AppArmor + profiles"

enable_system_service "apparmor.service"

warn "add 'lsm=landlock,lockdown,yama,integrity,apparmor,bpf' to the kernel"
warn "cmdline in /boot/limine/limine.conf by hand, then reboot for AppArmor"
_add_warning "add AppArmor LSM params to /boot/limine/limine.conf cmdline by hand, then reboot"
