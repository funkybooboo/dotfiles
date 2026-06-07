# 24-desktop-extras.sh — additional desktop/TUI tools

section "Desktop Extras"

info "installing additional desktop tools..."
install_pacman \
  blanket bluetui kvantum
install_aur calcure lazyjournal-bin lazysql-bin
[[ $DRY_RUN -eq 0 ]] && ok "desktop extras" || true