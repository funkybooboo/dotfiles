# 000600-rollforward.sh -- Generic runtime roll-forward (software upgrades only)
# Installs:  none (this migration only UPGRADES tools already installed by
#            earlier migrations; every step is guarded by `command -v`, so on
#            a machine without a given tool the step is a silent no-op).
# Links:     --
# Enables:   --
# Scope:     This migration is GENERIC: it upgrades installed package-managed
#            software (rustup, cargo, go, mise, npm, uv, pipx, gem, pnpm, bun,
#            pi, composer, ghcup/stack/cabal, tldr) under the deliberate
#            "trust upstream latest" policy (same principle as the Proton Drive
#            roll-forward in 000551). It knows NOTHING about the user's repos,
#            secrets, GitHub forks, ~/sources tree, or running containers --
#            those are personal/environment management and live in setup.sh,
#            not in migrate.sh.
# Note:      Unlike the audited, PINNED local PKGBUILDs (which intentionally do
#            NOT roll forward -- you bump the tracked PKGBUILD to update them),
#            the tools here are managed by their own upstream channels.
#            Re-running ./migrate.sh keeps installed runtimes current.
#            Dropped vs. the old `update` script: `pip install --user --upgrade
#            pip` (PEP 668 blocks it on Arch -- a silent no-op fighting the
#            system Python); GitHub fork sync + ~/sources rebuild + container
#            image pulls (moved to setup.sh as personal repo/environment
#            management). Firmware stays a separate manual `update-firmware`
#            (reboot-gated). Flatpak + Proton Drive updates are owned by 000301
#            and 000551 respectively.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "runtime roll-forward (update)"

# --- Rust toolchain + cargo crates ----------------------------------------------
if command -v rustup >/dev/null 2>&1; then
  info "rustup toolchain"
  if rustup update 2>/dev/null; then ok "rustup updated"; else warn "rustup update failed (non-fatal)"; fi
fi
if command -v cargo >/dev/null 2>&1; then
  info "cargo-installed crates"
  # cargo-update provides `cargo install-update`; install it if absent, then
  # upgrade every cargo-installed binary. Both best-effort.
  cargo install cargo-update 2>/dev/null || true
  if cargo install-update -a 2>/dev/null; then ok "cargo crates updated"; else warn "cargo crate update failed (non-fatal)"; fi
fi

# --- Go packages (re-install every ~/go/bin binary at @latest) ------------------
if command -v go >/dev/null 2>&1 && compgen -G "$HOME/go/bin/*" >/dev/null 2>&1; then
  info "Go packages"
  for _bin in "$HOME/go/bin/"*; do
    [[ -f "$_bin" ]] || continue
    _mod=$(go version -m "$_bin" 2>/dev/null | awk '/^\s+path/ {print $2}')
    if [[ -n "$_mod" ]]; then
      if go install "${_mod}@latest" 2>/dev/null; then
        ok "go: $_mod"
      else
        warn "go: could not update $_mod (non-fatal)"
      fi
    fi
  done
fi

# --- mise-managed runtimes (mise itself is upgraded by pacman/yay in 000001) ----
if command -v mise >/dev/null 2>&1; then
  info "mise-managed runtimes"
  if mise upgrade --yes 2>/dev/null; then ok "mise runtimes upgraded"; else warn "mise upgrade failed (non-fatal)"; fi
fi

# --- npm global packages --------------------------------------------------------
if command -v npm >/dev/null 2>&1; then
  info "npm global packages"
  if npm update -g 2>/dev/null; then ok "npm globals updated"; else warn "npm global update failed (non-fatal)"; fi
fi

# --- uv (Python tool manager) ---------------------------------------------------
if command -v uv >/dev/null 2>&1; then
  info "uv + uv-managed tools"
  uv self update 2>/dev/null || true
  if uv tool upgrade --all 2>/dev/null; then ok "uv tools upgraded"; else warn "uv tool upgrade failed (non-fatal)"; fi
fi

# --- Haskell (ghcup / stack / cabal) --------------------------------------------
if command -v ghcup >/dev/null 2>&1; then
  info "ghcup"
  ghcup upgrade 2>/dev/null || true
fi
if command -v stack >/dev/null 2>&1; then
  info "stack"
  stack upgrade 2>/dev/null || true
fi
if command -v cabal >/dev/null 2>&1; then
  info "cabal (Hackage index)"
  cabal update 2>/dev/null || true
fi

# --- pipx tools -----------------------------------------------------------------
if command -v pipx >/dev/null 2>&1; then
  info "pipx tools"
  if pipx upgrade-all 2>/dev/null; then ok "pipx tools upgraded"; else warn "pipx upgrade-all failed (non-fatal)"; fi
fi

# --- Ruby gems (user-install; harmless if no gems) ------------------------------
if command -v gem >/dev/null 2>&1; then
  info "Ruby gems"
  gem update --user-install 2>/dev/null || true
fi

# --- pnpm self-update -----------------------------------------------------------
if command -v pnpm >/dev/null 2>&1; then
  info "pnpm"
  pnpm add -g pnpm 2>/dev/null || true
fi

# --- bun self-update ------------------------------------------------------------
if command -v bun >/dev/null 2>&1; then
  info "bun"
  bun upgrade 2>/dev/null || true
fi

# --- Pi coding agent ------------------------------------------------------------
if command -v pi >/dev/null 2>&1; then
  info "Pi coding agent"
  pi update 2>/dev/null || true
fi

# --- Composer (PHP) -------------------------------------------------------------
if command -v composer >/dev/null 2>&1; then
  info "Composer (PHP)"
  composer self-update 2>/dev/null || true
  composer global update 2>/dev/null || true
fi

# --- tldr cache refresh ---------------------------------------------------------
if command -v tldr >/dev/null 2>&1; then
  info "tldr cache"
  tldr --update 2>/dev/null || true
fi

# --- Refresh shell caches (fzf fish init) --------------------------------------
rm -f ~/.cache/fzf_fish_init.fish 2>/dev/null || true

ok "runtime roll-forward complete"
