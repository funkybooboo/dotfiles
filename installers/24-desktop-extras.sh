# 24-desktop-extras.sh — additional desktop/TUI tools

section "Desktop Extras"

info "installing additional desktop tools..."
run_cmd sudo pacman -S --needed --noconfirm \
  blanket bluetui calcure kvantum svgject
run_cmd yay -S --needed --noconfirm \
  lazyjournal-bin lazysql-bin
[[ $DRY_RUN -eq 0 ]] && ok "desktop extras"