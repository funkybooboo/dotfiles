# 000001-system-update.sh — full system upgrade + AUR helper (yay)
# Installs: yay (via AUR build), git, base-devel (yay build deps)
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "System Update"

info "updating system packages..."
# Prefer `yay -Syu` when the AUR helper is present (covers Arch + AUR packages
# in one pass — this replaces the separate `yay -Syu` the old `update` script
# used to run). On a fresh machine yay is installed further down, so the first
# run falls back to `pacman -Syu`; every subsequent run uses yay.
if command -v yay >/dev/null 2>&1; then
  if yay -Syu --noconfirm; then
    ok "system updated (pacman + AUR via yay)"
  else
    warn "system update failed — continuing, but subsequent installs may be affected"
    _add_warning "yay -Syu failed; some packages may not install correctly"
  fi
else
  if sudo pacman -Syu --noconfirm; then
    ok "system updated (pacman; yay not yet installed)"
  else
    warn "system update failed — continuing, but subsequent installs may be affected"
    _add_warning "pacman -Syu failed; some packages may not install correctly"
  fi
fi
sudo systemctl daemon-reload 2>/dev/null || true

if command -v yay &>/dev/null; then
  skip "yay already installed"
else
  info "installing yay (AUR helper)..."
  if sudo pacman -S --needed --noconfirm git base-devel; then
    yay_tmp=$(mktemp -d)
    if git clone --quiet https://aur.archlinux.org/yay.git "$yay_tmp/yay" && \
       (cd "$yay_tmp/yay" && makepkg -si --noconfirm); then
      ok "yay installed"
    else
      warn "failed to build yay — AUR packages will not install until yay is set up manually"
      _add_warning "yay build failed; AUR packages will be skipped"
    fi
    rm -rf "$yay_tmp"
  else
    warn "failed to install yay build dependencies (git, base-devel)"
    _add_warning "yay build deps failed; AUR packages will be skipped"
  fi
fi
