# 000022-greetd.sh — greetd display manager + tuigreet greeter
# Installs: greetd greetd-tuigreet
# Links:    —
# Enables:  greetd.service

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "greetd"

install_pacman greetd
install_aur greetd-tuigreet
enable_system_service "greetd.service"
