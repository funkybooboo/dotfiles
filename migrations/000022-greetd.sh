# 000022-greetd.sh -- greetd display manager + tuigreet greeter
# Installs: greetd greetd-tuigreet (both in extra/ -- official Arch packages)
# Links:    --
# Enables:  greetd.service

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "greetd"

install_pacman greetd greetd-tuigreet

# Enable WITHOUT starting: greetd's default unit targets tty1, so starting it
# now would take over the active VT and kill this session mid-migration. It
# launches cleanly on the next reboot instead.
enable_system_service_no_start "greetd.service"

# The warning is transition signal, not steady state: it matters only between
# enabling greetd and the first reboot into it. Once greetd.service is ACTIVE
# the machine is already booting through it and a warning here would be noise
# on every future run (it showed up in every summary after the switch).
if systemctl is-active --quiet greetd.service 2>/dev/null; then
  skip "greetd.service (active -- machine boots through it)"
else
  warn "greetd enabled but NOT started -- it launches on next reboot"
  warn "(starting it now would grab the active TTY and disrupt this session)"
  _add_warning "greetd enabled but not started -- launches on next reboot (takes over tty1)"
fi
