# 000600-rollforward.sh -- Runtime roll-forward (runtimes + caches only)
# Installs:  none (this migration only UPGRADES runtimes + refreshes caches;
#            every step is guarded by `command -v`, so on a machine without
#            a given tool the step is a silent no-op).
# Links:     --
# Enables:   --
# Scope:     This migration is GENERIC: it upgrades mise-managed runtimes
#            (rust, go, node, python, zig, bun), nix profile packages, and
#            refreshes non-package caches (tldr, fzf). It does NOT install or
#            upgrade any language-ecosystem PACKAGES (no cargo crates, no
#            npm -g, no pip, no go install @latest, no gem, no pipx, no
#            composer). Language packages are per-project concerns managed
#            by each project's tooling (Cargo.lock, package-lock.json,
#            pyproject.toml, etc.).
#            pi update (coding agent self-update) stays -- it's a self-contained
#            tool, not a language-ecosystem package.
# Note:      nix flake update bumps the nixpkgs pin in flake.lock to latest,
#            then nix profile upgrade --all upgrades all nix-installed packages
#            to that new revision. This makes nix consistent with pacman -Syu
#            and flatpak update (always get upstream latest on each migrate run).
#            The flake.lock bump shows as an uncommitted change -- commit it to
#            pin the new revision across machines (same pattern as setup.sh
#            rolling forward sources/ submodules).
#            Firmware is opt-in via `./migrate.sh --firmware`, which runs
#            update-firmware after the migrations (reboot-gated, so not part of
#            a default run).
#            Flatpak + Proton Drive updates are owned by 000301 and 000551.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "runtime roll-forward (update)"

# --- pacman system packages (the fleet's largest layer) ---------------------
# The roll-forward policy (operator directive 2026-11-27): every migrate
# run upgrades everything, and pacman-managed software is most of it.
# install_pacman only installs-missing (--needed never upgrades), so the
# system upgrade lives here alongside the other roll-forward steps.
if command -v pacman >/dev/null 2>&1; then
  info "pacman system upgrade (arch packages)"
  if sudo pacman -Syu --noconfirm >/tmp/pacman_syu.log 2>&1; then
    ok "pacman packages up to date"
  else
    warn "pacman system upgrade reported an error (non-fatal):"
    tail -5 /tmp/pacman_syu.log 2>/dev/null | sed 's/^/    /' >&2
    _add_warning "pacman -Syu failed; system packages may be stale"
  fi
  rm -f /tmp/pacman_syu.log
fi

# --- mise-managed runtimes (rust, go, node, python, zig, bun) -------------------
# mise manages ALL language runtimes. mise upgrade updates each to the version
# pinned in ~/.config/mise/config.toml (global defaults) or the project's
# .mise.toml (per-project overrides). mise itself is upgraded by pacman in
# 000001. No separate rustup/go/npm/pip steps -- those are per-project.
if command -v mise >/dev/null 2>&1; then
  info "mise-managed runtimes"
  if mise upgrade --yes 2>/dev/null; then ok "mise runtimes upgraded"; else warn "mise upgrade failed (non-fatal)"; fi
fi

# --- nix profile packages (bump flake.lock pin, then upgrade all) --------------
if command -v nix >/dev/null 2>&1; then
  info "nix flake update (bump nixpkgs pin)"
  if nix flake update 2>/dev/null; then
    ok "flake.lock bumped to latest nixpkgs"
  else
    warn "nix flake update failed (non-fatal; using existing pin)"
  fi
  info "nix profile packages"
  if nix profile upgrade --all 2>/dev/null; then ok "nix packages upgraded"; else warn "nix profile upgrade failed (non-fatal)"; fi
fi

# --- nix itself (the installer-managed daemon/profile) -------------------------
# 000011 installs nix at a pinned release; routine updates run HERE per its
# own header note. `nix upgrade-nix` swaps the default profile's nix to the
# latest stable; a no-op when current. Guarded by the wrapper existing.
if command -v nix >/dev/null 2>&1; then
  info "nix itself"
  if nix upgrade-nix >/dev/null 2>&1; then
    ok "nix up to date ($(nix --version 2>/dev/null | head -1))"
  else
    warn "nix upgrade-nix failed (non-fatal)"
    _add_warning "nix: self-upgrade failed; check 'nix upgrade-nix' output"
  fi
fi

# --- tldr cache refresh (cache, not a package install) --------------------------
if command -v tldr >/dev/null 2>&1; then
  info "tldr cache"
  tldr --update 2>/dev/null || true
fi

# --- Refresh shell caches (fzf fish init) --------------------------------------
rm -f ~/.cache/fzf_fish_init.fish 2>/dev/null || true

ok "runtime roll-forward complete"
