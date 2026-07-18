# 000600-rollforward.sh -- Runtime roll-forward (runtimes + caches only)
# Installs:  none (this migration only UPGRADES runtimes + refreshes caches;
#            every step is guarded by `command -v`, so on a machine without
#            a given tool the step is a silent no-op).
# Links:     --
# Enables:   --
# Scope:     This migration is GENERIC: it upgrades mise-managed runtimes
#            (rust, go, node, python, zig, bun) and refreshes non-package
#            caches (tldr, fzf). It does NOT install or upgrade any language-
#            ecosystem PACKAGES (no cargo crates, no npm -g, no pip, no go
#            install @latest, no gem, no pipx, no composer). Language packages
#            are per-project concerns managed by each project's tooling
#            (Cargo.lock, package-lock.json, pyproject.toml, etc.).
#            pi update (coding agent self-update) stays — it's a self-contained
#            tool, not a language-ecosystem package.
# Note:      Unlike the audited, PINNED local PKGBUILDs (which intentionally do
#            NOT roll forward -- you bump the tracked PKGBUILD to update them),
#            the runtimes here are managed by mise under the deliberate
#            "trust upstream latest" policy. Re-running ./migrate.sh keeps
#            installed runtimes current.
#            Firmware stays a separate manual `update-firmware` (reboot-gated).
#            Flatpak + Proton Drive updates are owned by 000301 and 000551.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "runtime roll-forward (update)"

# --- mise-managed runtimes (rust, go, node, python, zig, bun) -------------------
# mise manages ALL language runtimes. mise upgrade updates each to the version
# pinned in ~/.config/mise/config.toml (global defaults) or the project's
# .mise.toml (per-project overrides). mise itself is upgraded by pacman in
# 000001. No separate rustup/go/npm/pip steps — those are per-project.
if command -v mise >/dev/null 2>&1; then
  info "mise-managed runtimes"
  if mise upgrade --yes 2>/dev/null; then ok "mise runtimes upgraded"; else warn "mise upgrade failed (non-fatal)"; fi
fi

# --- Pi coding agent (self-contained self-update, not a language package) --------
if command -v pi >/dev/null 2>&1; then
  info "Pi coding agent"
  pi update 2>/dev/null || true
fi

# --- tldr cache refresh (cache, not a package install) --------------------------
if command -v tldr >/dev/null 2>&1; then
  info "tldr cache"
  tldr --update 2>/dev/null || true
fi

# --- Refresh shell caches (fzf fish init) --------------------------------------
rm -f ~/.cache/fzf_fish_init.fish 2>/dev/null || true

ok "runtime roll-forward complete"
