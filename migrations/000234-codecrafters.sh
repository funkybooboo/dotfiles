# 000234-codecrafters.sh -- codecrafters CLI (nix flake)
# Nix:     .#codecrafters-cli
# Links:   --
# Enables: --
# Note: one piece of software = one migration. Provides the `codecrafters` CLI
#       (run tests / view results locally for codecrafters.io exercises,
#       faster than the commit-and-push git flow). Upstream ships only an
#       install script (curl|bash to ~/.codecrafters); the nix flake is the
#       cleanest prebuilt path (hermetic, sandboxed, PR-reviewed) and matches
#       the exercism CLI migration 000233. After install, run
#       `codecrafters login` once to authenticate.
#       Split out as its own dev-tools migration per the one-package-per-file
#       convention.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "codecrafters"

install_nix .#codecrafters-cli

ok "codecrafters"
