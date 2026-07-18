# 000550-cleanup-debug.sh — remove leftover -debug packages + yay
# Removes: stale *-debug packages from former -bin/-git installs, plus yay
#          (no longer used — nix replaces the AUR entirely).
# Installs: —
# Links:    —
# Enables:  —
# Note: Idempotent — remove_pkg skips anything already gone. On a fresh
#       install this is a no-op. On a machine that previously used the AUR,
#       it cleans up leftover debug packages + the yay helper.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "cleanup: stale debug packages + yay"

remove_pkg \
  apparmor.d-debug \
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
