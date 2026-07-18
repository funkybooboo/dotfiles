# 000001-system-update.sh — full system upgrade
# Installs: git, base-devel (build deps for pkgbuilds/)
# Links:    —
# Enables:  —
# Note: AUR/yay has been REMOVED from this system. System updates are
#       pacman-only (pacman -Syu). Packages not in Arch official repos
#       come from nix (tier 2), pkgbuilds/ (tier 3), sources/ (tier 4),
#       or flatpak (tier 5). The AUR is never used.

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

# git + base-devel are needed for makepkg (pkgbuilds/ tier). They may already
# be installed from archinstall; install_pacman --needed skips them.
install_pacman git base-devel
