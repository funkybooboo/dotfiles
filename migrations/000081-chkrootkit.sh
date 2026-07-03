# 000081-chkrootkit.sh — chkrootkit rootkit scanner + timers
# Installs: chkrootkit (local PKGBUILD, upstream source tarball)
# Deploys: /etc/systemd/system/chkrootkit-scan.{service,timer}
# Enables:  chkrootkit-scan.timer
# Note: chkrootkit is built from the upstream source tarball
#       (ftp.chkrootkit.org) via a local PKGBUILD — no yay/AUR at runtime.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "chkrootkit"

install_local_pkgbuild chkrootkit

deploy_etc_file "$DOTFILES_ROOT_ETC/systemd/system/chkrootkit-scan.service" \
  "/etc/systemd/system/chkrootkit-scan.service" 644
deploy_etc_file "$DOTFILES_ROOT_ETC/systemd/system/chkrootkit-scan.timer" \
  "/etc/systemd/system/chkrootkit-scan.timer" 644

enable_system_service "chkrootkit-scan.timer"
