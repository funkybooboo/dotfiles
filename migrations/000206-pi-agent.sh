# 000206-pi-agent.sh — pi coding agent (via nix) + config
# Nix:     .#pi-coding-agent (provides the `pi` binary, wraps ripgrep + fd)
# Links:   ~/.pi/**
# Enables: —
# Note: pi is installed from nixpkgs (hermetic buildNpmPackage, MIT licensed).
#       The nix package wraps `pi` with ripgrep + fd in PATH and sets
#       PI_SKIP_VERSION_CHECK=1 + PI_TELEMETRY=0. Upgrades via
#       nix profile upgrade --all (000600).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "pi agent"

install_nix .#pi-coding-agent
link_tree "$DOTFILES_HOME/.pi" "$HOME/.pi"
