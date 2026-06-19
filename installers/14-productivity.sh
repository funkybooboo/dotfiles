# 14-productivity.sh — file manager, office, notes, tools

section "Productivity"

info "installing productivity apps..."
install_pacman \
    thunar evince gnome-calculator gnome-disk-utility \
    gnome-keyring imagemagick libreoffice-fresh ghostscript \
    impala
install_aur signal-desktop losslesscut-bin cliamp
[[ $DRY_RUN -eq 0 ]] && ok "productivity apps" || true
