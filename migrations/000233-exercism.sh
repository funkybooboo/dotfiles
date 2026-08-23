# 000233-exercism.sh -- exercism CLI (nix flake)
# Nix:     .#exercism
# Links:   --
# Enables: --
# Note: one piece of software = one migration. Provides the `exercism` CLI used
#       by 2kabhishek/exercism.nvim (declared in nvim plugin spec
#       lua/plugins/exercism.lua). After install, run `exercism configure` once
#       (needs a token from exercism.io -> Account Settings -> API token) to
#       set the workspace + token before the plugin can fetch/test/submit.
#       Split out as its own dev-tools migration per the one-package-per-file
#       convention.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "exercism"

install_nix .#exercism

ok "exercism"
