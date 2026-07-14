# 000600-rollforward.sh -- Runtime roll-forward / update
# Installs:  none (this migration only UPGRADES tools already installed by
#            earlier migrations; every step is guarded by `command -v` or a
#            directory check, so on a machine without a given tool the step is
#            a silent no-op).
# Links:     --
# Enables:   --
# Note:      This migration consolidates the retired standalone `update` script
#            into the idempotent migrate pass. Unlike the audited, PINNED local
#            PKGBUILDs (which intentionally do NOT roll forward -- you bump the
#            tracked PKGBUILD to update them), the tools here are managed by
#            their own upstream channels (cargo, go, npm, uv, mise, pipx, gem,
#            pnpm, bun, pi, composer, ghcup, stack, cabal) under a deliberate
#            "trust upstream latest" policy (same principle as the Proton Drive
#            roll-forward in 000551). Re-running ./migrate.sh therefore keeps
#            everything current. Dropped vs. the old script: `pip install
#            --user --upgrade pip` (PEP 668 blocks it on Arch -- it was a silent
#            no-op fighting the system Python). Firmware updates stay a separate
#            manual `update-firmware` command (reboot-gated, potentially
#            disruptive). Flatpak + Proton Drive updates are owned by 000301
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

# --- Sync GitHub forks with upstream --------------------------------------------
if command -v gh >/dev/null 2>&1; then
  _forks=$(gh repo list --fork --limit 50 --json nameWithOwner --jq '.[].nameWithOwner' 2>/dev/null || true)
  if [[ -n "$_forks" ]]; then
    info "syncing GitHub forks with upstream"
    while IFS= read -r _repo; do
      if gh repo sync "$_repo" 2>/dev/null; then
        ok "fork synced: $_repo"
      else
        warn "could not sync fork: $_repo (non-fatal)"
      fi
    done <<< "$_forks"
  fi
fi

# --- ~/sources: git pull + incremental rebuild ---------------------------------
# Reusable build helper for the source-tree rebuild loop below. Ported verbatim
# in spirit from the retired `update` script. Each branch tries an incremental
# build in an existing build dir; `sudo make install` re-runs (idempotent for
# the autotools/make branches). Returns 0 on success, 1 on build failure,
# 2 if no recognized build system was found.
_rollforward_build_repo() {
  local repo="$1" name
  name=$(basename "$repo")

  local ninja_dir=""
  for d in "$repo"/Build/release "$repo"/build "$repo"/Build; do
    [[ -f "$d/build.ninja" ]] && { ninja_dir="$d"; break; }
  done
  if [[ -n "$ninja_dir" ]]; then
    if ninja -C "$ninja_dir" 2>/dev/null; then ok "$name (ninja)"; return 0; else warn "$name (ninja) failed"; return 1; fi
  fi

  local cmake_make_dir=""
  for d in "$repo"/Build/release "$repo"/build "$repo"/Build; do
    [[ -f "$d/Makefile" ]] && [[ -f "$repo/CMakeLists.txt" ]] && { cmake_make_dir="$d"; break; }
  done
  if [[ -n "$cmake_make_dir" ]]; then
    if make -C "$cmake_make_dir" 2>/dev/null; then ok "$name (cmake+make)"; return 0; else warn "$name (cmake+make) failed"; return 1; fi
  fi

  if [[ -f "$repo/configure" ]] && [[ ! -f "$repo/CMakeLists.txt" ]]; then
    if [[ ! -f "$repo/build/Makefile" ]]; then
      info "$name (configure: bootstrapping build/Makefile)"
      ( cd "$repo" && ./configure --launch-jobs="$(nproc)" --launch ) >/dev/null 2>&1 || true
    fi
    if [[ -f "$repo/build/Makefile" ]]; then
      # WARNING: sudo make install runs arbitrary install targets from source repos.
      if make -C "$repo/build" 2>/dev/null && sudo make -C "$repo/build" install 2>/dev/null; then
        ok "$name (make -C build)"; return 0
      else
        warn "$name (make -C build) failed"; return 1
      fi
    fi
  fi

  if [[ -f "$repo/go.mod" ]]; then
    if (cd "$repo" && go install ./... 2>/dev/null); then ok "$name (go install)"; return 0; else warn "$name (go install) failed"; return 1; fi
  fi
  if [[ -f "$repo/Cargo.toml" ]]; then
    if (cd "$repo" && cargo build --release 2>/dev/null); then ok "$name (cargo build)"; return 0; else warn "$name (cargo build) failed"; return 1; fi
  fi
  if [[ -f "$repo/meson.build" ]]; then
    if [[ -f "$repo/builddir/build.ninja" ]] && ninja -C "$repo/builddir" 2>/dev/null; then ok "$name (meson+ninja)"; return 0; else warn "$name (meson+ninja) failed"; return 1; fi
  fi
  if [[ -f "$repo/Makefile" || -f "$repo/makefile" ]] && [[ ! -f "$repo/CMakeLists.txt" ]]; then
    if make -C "$repo" 2>/dev/null && sudo make -C "$repo" install 2>/dev/null; then ok "$name (make)"; return 0; else warn "$name (make) failed"; return 1; fi
  fi
  if [[ -f "$repo/Gemfile" ]]; then
    if (cd "$repo" && bundle install 2>/dev/null); then ok "$name (bundle)"; return 0; else warn "$name (bundle) failed"; return 1; fi
  fi
  if [[ -f "$repo/package.json" ]]; then
    if (cd "$repo" && npm install 2>/dev/null && npm run build 2>/dev/null); then ok "$name (npm)"; return 0; else warn "$name (npm) failed"; return 1; fi
  fi

  return 2
}

if [[ -d "$HOME/sources" ]]; then
  info "Updating git repos in ~/sources"
  for _repo in "$HOME/sources"/*/; do
    [[ -d "$_repo/.git" ]] || continue
    _rname=$(basename "$_repo")
    if git -C "$_repo" pull --ff-only 2>/dev/null; then
      ok "$_rname (pulled)"
    else
      warn "$_rname (diverged or error -- non-fatal)"
    fi
  done

  info "Rebuilding ~/sources repos"
  for _repo in "$HOME/sources"/*/; do
    [[ -d "$_repo/.git" ]] || continue
    _rc=0
    _rollforward_build_repo "$_repo" || _rc=$?
    (( _rc == 2 )) && skip "$(basename "$_repo") (no recognized build system)"
  done
fi

# --- Docker / Podman container images (running containers only) -----------------
if command -v docker >/dev/null 2>&1 && sudo docker ps -q >/dev/null 2>&1; then
  info "Docker container images"
  for _ctr in $(sudo docker ps --format '{{.Names}}'); do
    _img=$(sudo docker inspect --format='{{.Config.Image}}' "$_ctr" 2>/dev/null || true)
    [[ -n "$_img" ]] || continue
    if sudo docker pull "$_img" 2>/dev/null; then ok "$_img ($_ctr)"; else warn "could not pull $_img (non-fatal)"; fi
  done
fi
if command -v podman >/dev/null 2>&1 && podman ps -q >/dev/null 2>&1; then
  info "Podman container images"
  for _ctr in $(podman ps --format '{{.Names}}'); do
    _img=$(podman inspect --format='{{.Config.Image}}' "$_ctr" 2>/dev/null || true)
    [[ -n "$_img" ]] || continue
    if podman pull "$_img" 2>/dev/null; then ok "$_img ($_ctr)"; else warn "could not pull $_img (non-fatal)"; fi
  done
fi

# --- Refresh shell caches (fzf fish init) --------------------------------------
rm -f ~/.cache/fzf_fish_init.fish 2>/dev/null || true

ok "runtime roll-forward complete"