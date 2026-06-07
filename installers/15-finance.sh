# 15-finance.sh — Monero GUI

section "Finance/Crypto"

info "installing finance/crypto apps..."
install_pacman monero-gui
[[ $DRY_RUN -eq 0 ]] && ok "finance/crypto apps" || true