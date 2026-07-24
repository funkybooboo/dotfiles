# 000566-losslesscut.sh -- losslesscut (nix flake)
# Nix:     .#losslesscut
# Links:   --
# Enables: --
# Note: one piece of software = one migration. losslesscut ships no upstream Linux
#       release tarball, so the nix flake is the cleanest prebuilt path
#       (hermetic, sandboxed, PR-reviewed). Split out of the former
#       000530-desktop-apps grab-bag.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "losslesscut"

install_nix .#losslesscut

ok "losslesscut"
