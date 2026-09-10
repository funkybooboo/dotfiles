# 000237-herdr.sh -- herdr (agent multiplexer; keeps coding-agent terminals alive)
# Nix:     .#herdr
# Links:   --
# Enables: --
# Note: absent from Arch's official repos (0 matching packages), and AUR is
#       excluded by policy, so tier 1 cannot serve it. Upstream DOES publish
#       release binaries behind an install.sh, so this is a deliberate skip past
#       tier 2 as well: that installer floats at latest where flake.lock pins a
#       revision, and the nixpkgs build additionally derives the shell completions
#       and the agent SKILL.md from the binary it just built (see its postInstall)
#       rather than shipping only the executable.
# Note: nothing is enabled here. The nixpkgs package installs no systemd unit --
#       its postInstall adds completions and share/herdr/skills/herdr/SKILL.md and
#       nothing else -- and none is needed: bare `herdr` launches or attaches the
#       persistent session, starting the server itself. `herdr server` (headless)
#       is what a user unit would wrap if boot-time autostart is ever wanted.
# Note: herdr ships a self-updater (`herdr update`, `herdr channel set`). Do not
#       use it. The binary it would replace lives in the read-only nix store, so
#       an update either fails or lands a second copy outside nix's control --
#       upgrades come from `nix profile upgrade --all` (000600) over a bumped
#       flake.lock. Config it reads: ~/.config/herdr/config.toml, untracked here;
#       `herdr --default-config` prints the default to start from.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "herdr"

install_nix .#herdr

ok "herdr"
