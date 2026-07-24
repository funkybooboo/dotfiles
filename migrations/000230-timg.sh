# 000230-timg.sh -- timg (nix flake)
# Nix:     .#timg
# Links:   --
# Enables: --
# Note: one piece of software = one migration. timg ships no upstream Linux
#       release tarball, so the nix flake is the cleanest prebuilt path
#       (hermetic, sandboxed, PR-reviewed). Split out of the former
#       000210-cli-utilities grab-bag.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "timg"

install_nix .#timg

ok "timg"
