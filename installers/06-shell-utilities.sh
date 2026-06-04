# 06-shell-utilities.sh — fish, fzf, ripgrep, fd, etc.

section "Shell Utilities"

info "installing shell utilities..."
run_cmd sudo pacman -S --needed --noconfirm \
  fish fzf ripgrep fd bat eza dust btop fastfetch jq wl-clipboard \
  starship zoxide tree tealdeer man-db less unzip rsync wget \
  atuin tmux ast-grep ncdu inotify-tools diffnav
run_cmd yay -S --needed --noconfirm gum
[[ $DRY_RUN -eq 0 ]] && ok "shell utilities"