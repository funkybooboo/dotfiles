# 000081-chkrootkit.sh — chkrootkit rootkit scanner + timers
# Installs: — (chkrootkit removed: unmaintained upstream, removed from nixpkgs,
#           not in Arch repos. rkhunter in 000080 covers the same role.)
# Deploys: /etc/systemd/system/chkrootkit-scan.{service,timer}
# Enables:  chkrootkit-scan.timer
# Note: chkrootkit was removed from nixpkgs (2025-09-12) because it was
#       "unmaintained and archived upstream and didn't even work on NixOS".
#       It's also not in Arch official repos. The existing pacman-installed
#       package (from the former pkgbuilds/) stays if already installed; on a
#       fresh machine, rkhunter (000080-rkhunter.sh) covers the same role and
#       IS actively maintained. The chkrootkit-scan timer/service are still
#       deployed in case the binary is present.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "chkrootkit"

# chkrootkit is not available from any trusted source (removed from nixpkgs,
# not in Arch repos, formerly from pkgbuilds/ which is now eliminated).
# The existing pacman-installed package stays if present. No new install.
if pacman -Q chkrootkit &>/dev/null; then
  ok "chkrootkit (already installed — stays; upstream is archived/unmaintained)"
else
  warn "chkrootkit not available from nix or pacman (upstream archived/unmaintained)"
  warn "rkhunter (000080) covers the same rootkit-scanning role"
  _add_warning "chkrootkit not installed (unmaintained upstream; rkhunter covers this)"
fi

deploy_etc_file "$DOTFILES_ROOT_ETC/systemd/system/chkrootkit-scan.service" \
  "/etc/systemd/system/chkrootkit-scan.service" 644
deploy_etc_file "$DOTFILES_ROOT_ETC/systemd/system/chkrootkit-scan.timer" \
  "/etc/systemd/system/chkrootkit-scan.timer" 644

enable_system_service_no_start "chkrootkit-scan.timer"
