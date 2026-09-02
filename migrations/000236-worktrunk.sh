# 000236-worktrunk.sh -- worktrunk (wt): git worktree CLI for parallel AI agents
# Installs: worktrunk (pacman, extra)
# Links:   -- (wt's fish files are tool-owned runtime artifacts, like gcx.fish)
# Enables: --
# Note: worktrunk.dev -- git worktree management (wt switch/list/merge/remove)
#       so 5-10+ AI agent sessions can work one branch each without stepping
#       on each other. Shell integration is REQUIRED for `wt switch` to cd;
#       for fish it is wrapper-based: `wt config shell install fish` writes
#       ~/.config/fish/functions/wt.fish (autoloaded stub that sources the
#       live function from the binary, so wt upgrades need no reinstall) plus
#       ~/.config/fish/completions/wt.fish. We target `fish` explicitly -- an
#       unfiltered install scans every detected shell and would append an
#       eval line to ~/.bashrc (bash exists on every Arch box even though fish
#       is the login shell). --yes skips the interactive confirm prompt so
#       migration runs stay non-interactive. Idempotent: with integration
#       already present the scan reports "already configured" and exits 0
#       without prompting. Takes effect in NEW fish sessions only.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "worktrunk (wt)"

install_pacman worktrunk

# --- fish shell integration (cd support for `wt switch`) -----------------------
# Guarded on wt actually being installed (install_pacman is non-fatal) and on
# fish being present (it is the login shell, but stay defensive -- this is a
# no-op on a fish-less machine). Non-fatal: without it `wt switch` still
# prints the target dir, it just cannot cd.
if command -v wt >/dev/null 2>&1 && command -v fish >/dev/null 2>&1; then
  # Output is left visible on purpose: "Created ..." on a fresh machine,
  # "Already configured" on every later run (that is the idempotent skip).
  if wt config shell install fish --yes; then
    ok "wt fish shell integration (functions/wt.fish + completions/wt.fish)"
  else
    warn "wt fish shell integration failed -- run manually: wt config shell install fish"
    _add_warning "worktrunk: fish shell integration failed (wt switch cannot cd)"
  fi
else
  skip "wt fish shell integration (wt or fish not available)"
fi

ok "worktrunk (wt)"