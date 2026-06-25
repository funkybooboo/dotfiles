# 000001-system-update.sh — full system upgrade + AUR helper (yay)
# Installs: yay (via AUR build), git, base-devel (yay build deps)
# Links:    —
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "System Update"

info "updating system packages..."
sudo pacman -Syu --noconfirm
ok "system updated"

if command -v yay &>/dev/null; then
  skip "yay already installed"
else
  info "installing yay (AUR helper)..."
  sudo pacman -S --needed --noconfirm git base-devel
  yay_tmp=$(mktemp -d)
  git clone --quiet https://aur.archlinux.org/yay.git "$yay_tmp/yay"
  (cd "$yay_tmp/yay" && makepkg -si --noconfirm)
  rm -rf "$yay_tmp"
  ok "yay installed"
fi
