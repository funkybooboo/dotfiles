# 000237-herdr.sh -- herdr (agent multiplexer; keeps coding-agent terminals alive)
# Nix:     .#herdr
# Links:   ~/.config/herdr/config.toml,
#          ~/.config/systemd/user/herdr.service
#          (~/.claude/skills/herdr/SKILL.md -- GENERATED here, see the note;
#           ~/.config/fish/functions/{hdl,hdlm,hsl,_herdr_*}.fish -- linked by
#           000101-fish's link_tree)
# Enables: herdr.service
# Note: absent from Arch's official repos (0 matching packages), and AUR is
#       excluded by policy, so tier 1 cannot serve it. Upstream DOES publish
#       release binaries behind an install.sh, so this is a deliberate skip past
#       tier 2 as well: that installer floats at latest where flake.lock pins a
#       revision, and the nixpkgs build additionally derives the shell completions
#       and the agent SKILL.md from the binary it just built (see its postInstall)
#       rather than shipping only the executable.
# Note: the unit is authored here because the package ships none, and without one
#       the client daemonizes the server into the cgroup of whichever terminal
#       surface spawned it (observed: app-ghostty-surface-transient-*.scope) --
#       tying a process that owns live agent panes to the lifetime of an
#       unrelated terminal window. Surviving logout or reaching a server before
#       first login additionally needs `loginctl enable-linger`, deliberately NOT
#       done here: agents that keep working unattended are a decision, not a
#       default.
# Note: the skill is GENERATED (`herdr --skill > ~/.claude/skills/herdr/
#       SKILL.md`) because herdr 0.9.0 stopped shipping the file in the
#       profile -- the 0.8 path share/herdr/skills/herdr/SKILL.md is gone,
#       share/skills/herdr/ is an empty scaffold. Generation also beats the
#       old profile-link: an upgrade can never leave a dangling link that
#       Claude Code reads as a broken skill. Machines still on 0.8 keep the
#       shipped-file fallback.
# Note: herdr ships a self-updater (`herdr update`, `herdr channel set`). Do not
#       use it. The binary it would replace lives in the read-only nix store, so
#       an update either fails or lands a second copy outside nix's control --
#       upgrades come from `nix profile upgrade --all` (000600) over a bumped
#       flake.lock.
# Note: config.toml is tracked even though herdr writes it too (`herdr config
#       reset-keys` backs it up and rewrites). A writer that saves by
#       temp-file-then-rename REPLACES the symlink with a real file, after which
#       edits stop reaching this repo silently. Re-running this migration repairs
#       it: link_file backs the stray file up first. The keymap is a tmux-parity
#       port from omarchy; the config's own header explains each binding.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "herdr"

install_nix .#herdr

link_file "$DOTFILES_HOME/.config/herdr/config.toml" "$HOME/.config/herdr/config.toml"
link_file "$DOTFILES_HOME/.config/systemd/user/herdr.service" \
  "$HOME/.config/systemd/user/herdr.service"

# The claude skill: generated, not linked. herdr 0.9.0 stopped shipping
# SKILL.md in the profile (the 0.8 path share/herdr/skills/herdr/SKILL.md is
# gone; share/skills/herdr/ exists but is empty) and `herdr --skill` prints it
# instead -- which is also safer than the link was: an upgrade can no longer
# leave a dangling link that Claude Code reads as a broken skill. Machines
# still on 0.8 pre-roll-forward keep the shipped-file fallback.
_claude_skill="$HOME/.claude/skills/herdr/SKILL.md"
_herdr_skill_v08="$HOME/.nix-profile/share/herdr/skills/herdr/SKILL.md"
mkdir -p "$(dirname "$_claude_skill")"
# A machine that ran the pre-0.9 skill-link keeps a DANGLING link here (its
# target died with the 0.9 upgrade), and bash follows it on the redirect
# below -- the write then fails with "No such file or directory" against the
# dead target directory. Sweep it first; on machines without the old link
# unlink_stale is silent.
unlink_stale "$_claude_skill"
if herdr --skill >"$_claude_skill" 2>/dev/null; then
  ok "herdr claude skill (generated) -> ${_claude_skill/$HOME/\~}"
elif [[ -f "$_herdr_skill_v08" ]]; then
  link_file "$_herdr_skill_v08" "$_claude_skill"
  ok "herdr claude skill (0.8 shipped file) -> ${_claude_skill/$HOME/\~}"
else
  warn "herdr --skill produced nothing and no shipped skill found"
  _add_warning "herdr claude skill not generated; herdr may be missing from the nix profile"
fi

enable_user_service "herdr.service"

ok "herdr"
