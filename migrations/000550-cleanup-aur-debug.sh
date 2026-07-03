# 000550-cleanup-aur-debug.sh — remove leftover AUR debug symbol packages
# Removes: the 12 *-debug packages pulled in by the former AUR -bin/-git
#          packages. Pure waste — they re-fetch on every rebuild and occupy
#          ~70 MiB. yay itself is kept (its -debug is removed too: the manager
#          needs no debug symbols).
# Installs: —
# Links:    —
# Enables:  —
# Note: Runs last (after 000500–000543 app migrations) so every base package
#       has already been swapped/removed by earlier migrations. Idempotent:
#       remove_pkg skips anything already gone.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "cleanup: AUR debug packages"

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
  yay-debug
