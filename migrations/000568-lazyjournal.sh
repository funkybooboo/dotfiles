# 000568-lazyjournal.sh -- lazyjournal (nix flake)
# Nix:     .#lazyjournal
# Links:   --
# Enables: --
# Note: one piece of software = one migration. lazyjournal ships no upstream Linux
#       release tarball, so the nix flake is the cleanest prebuilt path
#       (hermetic, sandboxed, PR-reviewed). Split out of the former
#       000530-desktop-apps grab-bag.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "lazyjournal"

install_nix .#lazyjournal

ok "lazyjournal"
