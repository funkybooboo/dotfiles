# 000540-lazycsv.sh -- lazycsv CSV viewer/editor (Rust TUI)
# Installs: -- (rust/cargo provided by mise, migration 000202)
# Links:    --
# Enables:  --
# Note: lazycsv is a Rust TUI for CSV files (github.com/funkybooboo/lazycsv).
#       Its source lives in the dotfiles git submodule sources/lazycsv
#       (initialized in preflight); it is built in release mode with cargo and
#       installed to ~/.local/bin so it is on PATH alongside the other
#       user-local binaries. The build uses the mise-managed Rust toolchain;
#       duckdb is built bundled (no system duckdb required).
#
#       Idempotency: building from source is expensive, so this migration only
#       rebuilds when the source actually changed. The submodule's commit SHA
#       (git -C sources/lazycsv rev-parse HEAD) is the fingerprint -- it only
#       moves when the submodule is bumped to a new commit. The last-built SHA
#       is recorded in ~/.local/share/lazycsv.stamp. Re-running ./migrate.sh
#       with the same submodule SHA + an existing binary is a fast skip; bump
#       the submodule (or delete the binary/stamp) to force a rebuild.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "lazycsv"

# Cargo must be available (provisioned by the mise migration, 000202).
if ! command -v cargo &>/dev/null; then
  fail "cargo not found -- run the mise migration (000202) first"
  _add_error "cargo not installed; cannot build lazycsv"
  exit 1
fi

LAZYCSV_DIR="$REPO_ROOT/sources/lazycsv"

# Verify the submodule is populated (a submodule's `.git` is a FILE, not a dir).
if [[ ! -e "$LAZYCSV_DIR/.git" ]]; then
  fail "sources/lazycsv submodule not populated"
  _add_error "sources/lazycsv submodule missing; run 'git -C ~/dotfiles submodule update --init sources/lazycsv'"
  exit 1
fi
ok "lazycsv source (submodule sources/lazycsv)"

# Idempotency: only rebuild when the source changed. The submodule commit
# SHA is the fingerprint; the last-built SHA lives in a stamp file. A missing
# binary or missing stamp also forces a rebuild.
LAZYCSV_BIN="$HOME/.local/bin/lazycsv"
LAZYCSV_STAMP="$HOME/.local/share/lazycsv.stamp"
LAZYCSV_SHA="$(git -C "$LAZYCSV_DIR" rev-parse HEAD 2>/dev/null || echo unknown)"
LAZYCSV_STAMPED_SHA="$(cat "$LAZYCSV_STAMP" 2>/dev/null || echo none)"

if [[ -x "$LAZYCSV_BIN" && -f "$LAZYCSV_STAMP" \
      && "$LAZYCSV_SHA" == "$LAZYCSV_STAMPED_SHA" ]]; then
  skip "lazycsv (up to date at ${LAZYCSV_SHA:0:12})"
  exit 0
fi

if [[ ! -x "$LAZYCSV_BIN" ]]; then
  info "building lazycsv (binary missing)"
elif [[ "$LAZYCSV_SHA" != "$LAZYCSV_STAMPED_SHA" ]]; then
  info "building lazycsv (source changed: ${LAZYCSV_STAMPED_SHA:0:12} -> ${LAZYCSV_SHA:0:12})"
else
  info "building lazycsv (stamp missing)"
fi

# Build in release mode and install to ~/.local/bin.
info "building lazycsv (cargo build --release)..."
if (cd "$LAZYCSV_DIR" && cargo build --release); then
  ok "lazycsv built (release)"
else
  fail "lazycsv build failed"
  _add_error "lazycsv build failed; run 'cargo build --release' in $LAZYCSV_DIR"
  exit 1
fi

info "installing lazycsv -> ~/.local/bin..."
if (cd "$LAZYCSV_DIR" && cargo install --path . --root "$HOME/.local" --force); then
  ok "lazycsv installed to ~/.local/bin/lazycsv"
else
  fail "lazycsv install failed"
  _add_error "lazycsv install failed; run 'cargo install --path . --root ~/.local' in $LAZYCSV_DIR"
  exit 1
fi

# Record the source SHA we just built from, so a re-run with the same source
# is a fast skip. mkdir in case ~/.local/share does not yet exist.
mkdir -p "$(dirname "$LAZYCSV_STAMP")"
printf '%s\n' "$LAZYCSV_SHA" > "$LAZYCSV_STAMP"
ok "lazycsv stamp recorded (${LAZYCSV_SHA:0:12})"
