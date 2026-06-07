# 11-terminal.sh — terminal emulators

section "Terminal Emulators"

info "installing terminal emulators..."
install_aur ghostty
[[ $DRY_RUN -eq 0 ]] && ok "terminal emulators" || true