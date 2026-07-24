# 000569-lazysql.sh -- lazysql (nix flake)
# Nix:     .#lazysql
# Links:   --
# Enables: --
# Note: one piece of software = one migration. lazysql ships no upstream Linux
#       release tarball, so the nix flake is the cleanest prebuilt path
#       (hermetic, sandboxed, PR-reviewed). Split out of the former
#       000530-desktop-apps grab-bag.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "lazysql"

install_nix .#lazysql

ok "lazysql"
