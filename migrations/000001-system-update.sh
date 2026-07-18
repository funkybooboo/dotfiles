# 000001-system-update.sh — full system upgrade
# Installs: git, base-devel (needed by migrations + makepkg)
# Links:    —
# Enables:  —
# Note: System updates are pacman-only (pacman -Syu). Packages not in Arch
#       official repos come from nix (tier 2), sources/ (tier 3), or flatpak
#       (tier 4). The AUR is never used.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "System Update"

info "updating system packages..."
if sudo pacman -Syu --noconfirm; then
  ok "system updated (pacman)"
else
  warn "system update failed — continuing, but subsequent installs may be affected"
  _add_warning "pacman -Syu failed; some packages may not install correctly"
fi
sudo systemctl daemon-reload 2>/dev/null || true

# git + base-devel are needed by later migrations. They may already be
# installed from archinstall; install_pacman --needed skips them.
install_pacman git base-devel
