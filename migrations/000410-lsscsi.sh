# 000410-lsscsi.sh -- lsscsi (pacman)
# Installs: lsscsi
# Links:    --
# Enables:  --
# Note: one piece of software = one migration. Tier 1 -- lsscsi 0.32 is in
#       Arch extra, so no nix or upstream-release path is needed.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "lsscsi"

install_pacman lsscsi

ok "lsscsi"
