# 000402-network.sh — network stack + networkd-wait-online override
# Installs: iwd wireless-regdb bind openresolv
# Deploys: /etc/systemd/system/systemd-networkd-wait-online.service.d/override.conf
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "network"

install_pacman iwd wireless-regdb bind openresolv

deploy_etc_file \
  "$DOTFILES_ROOT_ETC/systemd/system/systemd-networkd-wait-online.service.d/override.conf" \
  "/etc/systemd/system/systemd-networkd-wait-online.service.d/override.conf" 644

# The override changes ExecStart, so reload systemd to pick it up
sudo systemctl daemon-reload 2>/dev/null || true
