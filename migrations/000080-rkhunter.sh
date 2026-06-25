# 000080-rkhunter.sh — rkhunter rootkit scanner + config + timers
# Installs: rkhunter
# Deploys: /etc/rkhunter.conf, /etc/pacman.d/hooks/rkhunter-propupd.hook,
#          /etc/systemd/system/rkhunter-scan.{service,timer}
# Enables:  rkhunter-scan.timer

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "rkhunter"

install_pacman rkhunter

deploy_etc_file "$DOTFILES_ROOT_ETC/rkhunter.conf" "/etc/rkhunter.conf" 640
deploy_etc_file "$DOTFILES_ROOT_ETC/pacman.d/hooks/rkhunter-propupd.hook" \
  "/etc/pacman.d/hooks/rkhunter-propupd.hook" 644
deploy_etc_file "$DOTFILES_ROOT_ETC/systemd/system/rkhunter-scan.service" \
  "/etc/systemd/system/rkhunter-scan.service" 644
deploy_etc_file "$DOTFILES_ROOT_ETC/systemd/system/rkhunter-scan.timer" \
  "/etc/systemd/system/rkhunter-scan.timer" 644

# Initialize rkhunter file properties database
if command -v rkhunter &>/dev/null; then
  if [[ ! -f /var/lib/rkhunter/db/rkhunter.dat ]]; then
    info "initializing rkhunter file properties database..."
    sudo rkhunter --propupd 2>/dev/null || true
    ok "rkhunter database initialized"
  else
    skip "rkhunter database (already exists)"
  fi
fi

enable_system_service "rkhunter-scan.timer"
