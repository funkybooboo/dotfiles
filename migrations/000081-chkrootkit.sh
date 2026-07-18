# 000081-chkrootkit.sh — chkrootkit rootkit scanner + timers
# Installs: chkrootkit (via nix — nixpkgs#chkrootkit)
# Deploys: /etc/systemd/system/chkrootkit-scan.{service,timer}
# Enables:  chkrootkit-scan.timer
# Note: chkrootkit is installed from nixpkgs — hermetic, sandboxed build,
#       sha256-verified source from chkrootkit.org, no pkgbuilds/ needed.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "chkrootkit"

install_nix nixpkgs#chkrootkit

deploy_etc_file "$DOTFILES_ROOT_ETC/systemd/system/chkrootkit-scan.service" \
  "/etc/systemd/system/chkrootkit-scan.service" 644
deploy_etc_file "$DOTFILES_ROOT_ETC/systemd/system/chkrootkit-scan.timer" \
  "/etc/systemd/system/chkrootkit-scan.timer" 644

enable_system_service_no_start "chkrootkit-scan.timer"
