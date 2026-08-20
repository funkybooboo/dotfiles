# 000001-system-update.sh -- full system upgrade
# Installs: git, base-devel / build-essential (needed by later migrations)
# Links:    --
# Enables:  --
# Note: The upgrade command is the one distro-specific step here (pacman -Syu
#       vs apt-get upgrade). Packages not in the distro's official repos come
#       from upstream releases (tier 2), nix (tier 3), sources/, or flatpak.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "System Update"

info "updating system packages..."
if is_debian; then
  if sudo apt-get update -y && \
       sudo DEBIAN_FRONTEND=noninteractive apt-get -y upgrade; then
    ok "system updated (apt)"
  else
    warn "system update failed -- continuing, but subsequent installs may be affected"
    _add_warning "apt upgrade failed; some packages may not install correctly"
  fi
else
  if sudo pacman -Syu --noconfirm; then
    ok "system updated (pacman)"
  else
    warn "system update failed -- continuing, but subsequent installs may be affected"
    _add_warning "pacman -Syu failed; some packages may not install correctly"
  fi
fi
sudo systemctl daemon-reload 2>/dev/null || true

# A C toolchain + git are needed by later migrations that build from source.
# Both package managers' meta-packages are no-ops when already present.
if is_debian; then
  install_apt git build-essential
else
  install_pacman git base-devel
fi
