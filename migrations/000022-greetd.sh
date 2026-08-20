# 000022-greetd.sh -- greetd display manager + tuigreet greeter
# Installs: greetd greetd-tuigreet (Arch: both in extra/; Debian: greetd + tuigreet)
# Links:    --
# Enables:  greetd.service
# Note: OPT-IN on Debian/Ubuntu. Those installs normally already have a display
#       manager (GDM/LightDM), and switching it out from under a machine you did
#       not provision is disruptive -- so on Debian this migration does nothing
#       unless DOTFILES_ENABLE_GREETD=1 is set. On Arch greetd IS the display
#       manager this repo provisions, so it runs unconditionally.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "greetd"

if is_debian; then
  if [[ "${DOTFILES_ENABLE_GREETD:-0}" != "1" ]]; then
    skip "greetd (set DOTFILES_ENABLE_GREETD=1 to replace the existing display manager)"
    return 0 2>/dev/null || exit 0
  fi
  # Debian packages the greeter as 'tuigreet', not 'greetd-tuigreet'.
  install_apt greetd tuigreet
else
  install_pacman greetd greetd-tuigreet
fi

# Enable WITHOUT starting: greetd's default unit targets tty1, so starting it
# now would take over the active VT and kill this session mid-migration. It
# launches cleanly on the next reboot instead.
enable_system_service_no_start "greetd.service"
warn "greetd enabled but NOT started -- it launches on next reboot"
warn "(starting it now would grab the active TTY and disrupt this session)"
_add_warning "greetd enabled but not started -- launches on next reboot (takes over tty1)"

# Enable WITHOUT starting: greetd's default unit targets tty1, so starting it
# now would take over the active VT and kill this session mid-migration. It
# launches cleanly on the next reboot instead.
enable_system_service_no_start "greetd.service"
warn "greetd enabled but NOT started -- it launches on next reboot"
warn "(starting it now would grab the active TTY and disrupt this session)"
_add_warning "greetd enabled but not started -- launches on next reboot (takes over tty1)"
