# 000405-firewall.sh — UFW firewall + ufw-docker
# Installs: ufw ufw-docker
# Links:    —
# Enables:  ufw.service

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "firewall"

install_pacman ufw
install_aur ufw-docker

# Enable WITHOUT starting: `ufw enable` applies default-deny immediately and
# would drop an active SSH session (or any remote connection) with no allow
# rule yet in place. It activates on the next reboot instead.
enable_system_service_no_start "ufw.service"
warn "ufw enabled but NOT started — it activates on next reboot"
warn "BEFORE rebooting: verify SSH/needed ports are allowed, e.g."
warn "  sudo ufw allow ssh   # or: sudo ufw allow 22/tcp"
_add_warning "ufw enabled but not started — confirm SSH/needed ports are allowed before reboot or you may be locked out"
