# 000540-lazycsv.sh — lazycsv CSV viewer/editor (Rust TUI)
# Installs: — (rust/cargo provided by mise, migration 000202)
# Links:    —
# Enables:  —
# Note: lazycsv is a Rust TUI for CSV files (github.com/funkybooboo/lazycsv).
#       It is cloned into ~/sources/lazycsv (idempotent), built in release mode
#       with cargo, and installed to ~/.local/bin so it is on PATH alongside
#       the other user-local binaries. The build uses the mise-managed Rust
#       toolchain; duckdb is built bundled (no system duckdb required).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "lazycsv"

# Cargo must be available (provisioned by the mise migration, 000202).
if ! command -v cargo &>/dev/null; then
  fail "cargo not found — run the mise migration (000202) first"
  _add_error "cargo not installed; cannot build lazycsv"
  exit 1
fi

LAZYCSV_DIR="$HOME/sources/lazycsv"

# Clone idempotently.
if [[ -d "$LAZYCSV_DIR/.git" ]]; then
  skip "lazycsv repo (already cloned)"
else
  info "cloning lazycsv → ~/sources/lazycsv..."
  mkdir -p "$HOME/sources"
  if git clone --quiet https://github.com/funkybooboo/lazycsv.git "$LAZYCSV_DIR"; then
    ok "lazycsv cloned"
  else
    fail "failed to clone lazycsv"
    _add_error "lazycsv clone failed; run 'git clone https://github.com/funkybooboo/lazycsv.git ~/sources/lazycsv'"
    exit 1
  fi
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

info "installing lazycsv → ~/.local/bin..."
if (cd "$LAZYCSV_DIR" && cargo install --path . --root "$HOME/.local" --force); then
  ok "lazycsv installed to ~/.local/bin/lazycsv"
else
  fail "lazycsv install failed"
  _add_error "lazycsv install failed; run 'cargo install --path . --root ~/.local' in $LAZYCSV_DIR"
  exit 1
fi
