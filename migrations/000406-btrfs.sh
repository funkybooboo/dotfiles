# 000406-btrfs.sh -- Btrfs tools + snapper + swappiness sysctl
# Installs: btrfs-progs snapper
# Deploys: /etc/sysctl.d/99-swappiness.conf
# Enables:  --

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "btrfs"

if is_debian; then
  # Only install btrfs tools if the root filesystem is actually btrfs.
  # Ubuntu typically uses ext4; installing snapper on ext4 is pointless.
  if [[ "$(stat -f -c %T /)" == "btrfs" ]]; then
    install_apt btrfs-progs snapper
  else
    skip "btrfs tools (root fs is not btrfs on Debian -- skipping)"
  fi
else
  install_pacman btrfs-progs snapper
fi

deploy_etc_file "$DOTFILES_ROOT_ETC/sysctl.d/99-swappiness.conf" \
  "/etc/sysctl.d/99-swappiness.conf" 644
if command -v sysctl &>/dev/null; then
  sudo sysctl -p /etc/sysctl.d/99-swappiness.conf >/dev/null 2>&1 || true
fi
