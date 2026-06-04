# 11-terminal.sh — terminal emulators

section "Terminal Emulators"

info "installing terminal emulators..."
run_cmd yay -S --needed --noconfirm ghostty
[[ $DRY_RUN -eq 0 ]] && ok "terminal emulators"