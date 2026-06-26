# 000022-greetd.sh — greetd display manager + tuigreet greeter
# Installs: greetd greetd-tuigreet
# Links:    —
# Enables:  greetd.service

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "greetd"

install_pacman greetd
install_aur greetd-tuigreet

# Enable WITHOUT starting: greetd's default unit targets tty1, so starting it
# now would take over the active VT and kill this session mid-migration. It
# launches cleanly on the next reboot instead.
enable_system_service_no_start "greetd.service"
warn "greetd enabled but NOT started — it launches on next reboot"
warn "(starting it now would grab the active TTY and disrupt this session)"
_add_warning "greetd enabled but not started — launches on next reboot (takes over tty1)"
