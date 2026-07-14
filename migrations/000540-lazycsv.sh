# 000540-lazycsv.sh — lazycsv CSV viewer/editor (Rust TUI)
# Installs: — (rust/cargo provided by mise, migration 000202)
# Links:    —
# Enables:  —
# Note: lazycsv is a Rust TUI for CSV files (github.com/funkybooboo/lazycsv).
#       Its source lives in the dotfiles git submodule sources/lazycsv
#       (initialized in preflight); it is built in release mode with cargo and
#       installed to ~/.local/bin so it is on PATH alongside the other
#       user-local binaries. The build uses the mise-managed Rust toolchain;
#       duckdb is built bundled (no system duckdb required).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "lazycsv"

# Cargo must be available (provisioned by the mise migration, 000202).
if ! command -v cargo &>/dev/null; then
  fail "cargo not found — run the mise migration (000202) first"
  _add_error "cargo not installed; cannot build lazycsv"
  exit 1
fi

LAZYCSV_DIR="$REPO_ROOT/sources/lazycsv"

# Verify the submodule is populated.
if [[ ! -d "$LAZYCSV_DIR/.git" ]]; then
  fail "sources/lazycsv submodule not populated"
  _add_error "sources/lazycsv submodule missing; run 'git -C ~/dotfiles submodule update --init sources/lazycsv'"
  exit 1
fi
ok "lazycsv source (submodule sources/lazycsv)"

# Build in release mode and install to ~/.local/bin.
info "building lazycsv (cargo build --release)..."
if (cd "$LAZYCSV_DIR" && cargo build --release); then
  ok "lazycsv built (release)"
else
  fail "lazycsv build failed"
  _add_error "lazycsv build failed; run 'cargo build --release' in $LAZYCSV_DIR"
  exit 1
fi

info "installing lazycsv → ~/.local/bin..."
if (cd "$LAZYCSV_DIR" && cargo install --path . --root "$HOME/.local" --force); then
  ok "lazycsv installed to ~/.local/bin/lazycsv"
else
  fail "lazycsv install failed"
  _add_error "lazycsv install failed; run 'cargo install --path . --root ~/.local' in $LAZYCSV_DIR"
  exit 1
fi
