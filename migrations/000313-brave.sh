# 000313-brave.sh -- Brave web browser (nix flake)
# Nix:    .#brave  (local flake, allowUnfree = true, sha256-verified hermetic)
# Links:  --
# Enables: --
# Note: one piece of software = one migration. Brave ships no upstream Linux
#       release tarball/appimage on brave.com (only the .deb/.rpm via the
#       seen-on-brave.com repo), so the nix flake is the cleanest prebuilt
#       binary path -- hermetic, PR-reviewed, binary-cached. The other
#       browsers live in 000303-firefox, 000309-chromium, 000307-librewolf,
#       000308-mullvad-browser.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "brave"

install_nix .#brave

ok "brave"