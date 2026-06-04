# 14-productivity.sh — file manager, office, notes, tools

section "Productivity"

info "installing productivity apps..."
run_cmd sudo pacman -S --needed --noconfirm \
  thunar evince gnome-calculator gnome-disk-utility \
  gnome-keyring imagemagick
run_cmd yay -S --needed --noconfirm obsidian signal-desktop losslesscut-bin
[[ $DRY_RUN -eq 0 ]] && ok "productivity apps"