# 00-system-update.sh — system update + AUR helper

section "System Update"

info "updating system packages..."
run_cmd sudo pacman -Syu --noconfirm
[[ $DRY_RUN -eq 0 ]] && ok "system updated" || true

if command -v yay &>/dev/null; then
  skip "yay already installed"
elif [[ $DRY_RUN -eq 1 ]]; then
  info "would install yay (AUR helper)"
else
  info "installing yay (AUR helper)..."
  sudo pacman -S --needed --noconfirm git base-devel
  yay_tmp=$(mktemp -d)
  git clone --quiet https://aur.archlinux.org/yay.git "$yay_tmp/yay"
  (cd "$yay_tmp/yay" && makepkg -si --noconfirm)
  rm -rf "$yay_tmp"
  ok "yay installed"
fi