# 000550-cleanup-aur-debug.sh — remove leftover AUR packages + yay
# Removes: the 12 *-debug packages pulled in by the former AUR -bin/-git
#          packages, PLUS yay itself (the AUR helper is no longer used —
#          the AUR is eliminated from this system).
# Installs: —
# Links:    —
# Enables:  —
# Note: Runs last (after 000500–000543 app migrations) so every base package
#       has already been swapped/removed by earlier migrations. Idempotent:
#       remove_pkg skips anything already gone. yay + yay-debug are removed
#       here because the AUR is no longer an install tier (pacman → nix →
#       pkgbuilds → sources → flatpak).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "cleanup: AUR packages + yay"

remove_pkg \
  apparmor.d-debug \
  chkrootkit-debug \
  cliamp-debug \
  lazyjournal-bin-debug \
  lazysql-bin-debug \
  librewolf-bin-debug \
  losslesscut-bin-debug \
  proton-pass-bin-debug \
  proton-pass-cli-bin-debug \
  tdf-debug \
  timg-debug \
  yay-debug \
  yay
