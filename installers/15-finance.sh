# 15-finance.sh — Monero GUI

section "Finance/Crypto"

info "installing finance/crypto apps..."
run_cmd sudo pacman -S --needed --noconfirm monero-gui
[[ $DRY_RUN -eq 0 ]] && ok "finance/crypto apps"