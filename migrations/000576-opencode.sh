# 000576-opencode.sh -- opencode (nix)
# Nix:     .#opencode
# Links:   --
# Enables: --
# Note: one piece of software = one migration. opencode is the terminal AI
#       coding agent from SST (opencode.ai). Installed via the pinned nixpkgs
#       flake attr (hermetic, sandboxed). Free models: opencode ships with
#       built-in access to free tiers (e.g. OpenRouter free models, Google
#       AI Studio) -- run `opencode auth login` to wire a provider, or use the
#       free models directly from the model picker. No API key required for the
#       free tiers; bring your own key for paid models.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "opencode"

install_nix .#opencode

ok "opencode"
