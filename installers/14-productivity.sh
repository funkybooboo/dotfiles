# 14-productivity.sh — file manager, office, notes, tools

section "Productivity"

info "installing productivity apps..."
install_pacman \
  thunar evince gnome-calculator gnome-disk-utility \
  gnome-keyring imagemagick libreoffice-fresh
install_aur obsidian signal-desktop losslesscut-bin
[[ $DRY_RUN -eq 0 ]] && ok "productivity apps" || true