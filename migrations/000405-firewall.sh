# 000405-firewall.sh — UFW firewall + ufw-docker
# Installs: ufw ufw-docker
# Links:    —
# Enables:  ufw.service

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "firewall"

install_pacman ufw
install_aur ufw-docker
enable_system_service "ufw.service"
