# 000406-btrfs.sh — Btrfs tools + snapper + swappiness sysctl
# Installs: btrfs-progs snapper
# Deploys: /etc/sysctl.d/99-swappiness.conf
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "btrfs"

install_pacman btrfs-progs snapper

deploy_etc_file "$DOTFILES_ROOT_ETC/sysctl.d/99-swappiness.conf" \
  "/etc/sysctl.d/99-swappiness.conf" 644
if command -v sysctl &>/dev/null; then
  sudo sysctl -p /etc/sysctl.d/99-swappiness.conf >/dev/null 2>&1 || true
fi
