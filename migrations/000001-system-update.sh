# 000001-system-update.sh -- full system upgrade
# Installs: git, base-devel (needed by migrations + makepkg)
# Links:    --
# Enables:  --
# Note: System updates are pacman-only (pacman -Syu). Packages not in Arch
#       official repos come from upstream release assets (tier 2), nix
#       (tier 3), from source (tier 4), or flatpak (tier 5):
#       pacman -> upstream assets -> nix -> source -> flatpak
#       (see docs/packages.md).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "System Update"

info "updating system packages..."
if sudo pacman -Syu --noconfirm; then
  ok "system updated (pacman)"
else
  warn "system update failed -- continuing, but subsequent installs may be affected"
  _add_warning "pacman -Syu failed; some packages may not install correctly"
fi
sudo systemctl daemon-reload 2>/dev/null || true

# git + base-devel are needed by later migrations. They may already be
# installed from archinstall; install_pacman --needed skips them.
install_pacman git base-devel
