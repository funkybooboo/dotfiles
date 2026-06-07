# 06-shell-utilities.sh — fish, fzf, ripgrep, fd, etc.

section "Shell Utilities"

info "installing shell utilities..."
install_pacman \
  fish fzf ripgrep fd bat eza dust btop fastfetch jq wl-clipboard \
  starship zoxide tree tealdeer man-db less unzip rsync wget \
  atuin tmux ast-grep ncdu inotify-tools diffnav
install_aur gum
[[ $DRY_RUN -eq 0 ]] && ok "shell utilities" || true