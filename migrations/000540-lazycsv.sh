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
#       rebuilds when the source actually changed. source_built_current compares
#       the submodule's commit SHA against the last-built one recorded under
#       ~/.cache/dotfiles-sources; bump the submodule, or delete the binary or the
#       stamp, to force a rebuild.
#
#       Nothing here is fatal. A missing cargo or an unpopulated submodule skips
#       the build and lets the rest of the run continue, rather than aborting
#       migrate.sh at this point and taking every later migration with it.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "lazycsv"

# Cargo must be available (provisioned by the mise migration, 000202).
if ! command -v cargo &>/dev/null; then
  warn "cargo not found -- run the mise migration (000202) first"
  _add_warning "cargo not installed; cannot build lazycsv"
  return 0 2>/dev/null || exit 0
fi

source_ready lazycsv || { return 0 2>/dev/null || exit 0; }

if source_built_current lazycsv "$HOME/.local/bin/lazycsv"; then
  skip "lazycsv (built from current sources/lazycsv)"
  ok "lazycsv"
  return 0 2>/dev/null || exit 0
fi

# `cargo install --path .` builds release and installs in one step, so there is no
# separate `cargo build` to fail independently.
info "building + installing lazycsv (cargo install --path . --root ~/.local)..."
if (cd "$DOTFILES_SOURCES/lazycsv" && cargo install --path . --root "$HOME/.local" --force); then
  source_mark_built lazycsv
  ok "lazycsv installed -> ~/.local/bin/lazycsv"
else
  warn "lazycsv build/install failed"
  _add_warning "lazycsv build failed; run 'cargo install --path . --root ~/.local' in sources/lazycsv"
fi
