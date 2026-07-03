# 000208-neovim-node-host.sh — REMOVE the Neovim Node.js provider host
# Removes: the "neovim" npm global package (provides neovim-node-host)
# Links:    —
# Enables:  —
# Note: Superseded. The nvim config uses nvim-lspconfig + typescript-language-
#       server (an LSP server) for JS/TS; there are ZERO node-host remote
#       plugins in the config. The node_host_prog / NODE_PATH lines in
#       options.lua were cosmetic (only silenced :checkhealth vim.provider)
#       and have been removed from the tracked config. This migration
#       uninstalls the npm global so no third-party npm package remains.
#       Idempotent: skips when already gone. Runs AFTER 000202-mise (provisions
#       node/npm via mise) so npm is available.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "neovim node host (removal)"

HOST_BIN="$HOME/.local/bin/neovim-node-host"
MOD_DIR="$HOME/.local/lib/node_modules/neovim"

# Resolve npm/node: PATH first, then mise shims (migrate.sh is non-interactive).
resolve_cmd() {
  local _name="$1"
  if command -v "$_name" &>/dev/null; then
    command -v "$_name"; return 0
  fi
  local _shim="$HOME/.local/share/mise/shims/$_name"
  if [[ -x "$_shim" ]]; then echo "$_shim"; return 0; fi
  return 1
}

if [[ ! -e "$HOST_BIN" ]] && [[ ! -d "$MOD_DIR" ]]; then
  skip "neovim npm global (already removed)"
else
  if ! NPM="$(resolve_cmd npm)"; then
    warn "npm not found — cannot uninstall neovim global; remove manually:"
    warn "  rm -rf ~/.local/lib/node_modules/neovim ~/.local/bin/neovim-node-host"
    _add_warning "npm not available; neovim npm global not removed"
  else
    info "uninstalling neovim npm global (neovim-node-host) from ~/.local"
    if "$NPM" uninstall -g --prefix "$HOME/.local" neovim 2>/dev/null; then
      ok "neovim npm global removed"
    else
      # npm uninstall can be flaky with custom prefixes; manual fallback.
      rm -rf "$MOD_DIR" "$HOST_BIN" 2>/dev/null || true
      if [[ ! -e "$HOST_BIN" ]] && [[ ! -d "$MOD_DIR" ]]; then
        ok "neovim npm global removed (manual fallback)"
      else
        warn "could not fully remove neovim npm global — check $MOD_DIR"
        _add_warning "neovim npm global not fully removed"
      fi
    fi
  fi
fi

# Final sanity: nothing should remain.
if [[ -e "$HOST_BIN" ]] || [[ -d "$MOD_DIR" ]]; then
  warn "residual neovim node-host files remain — remove manually:"
  warn "  rm -rf $MOD_DIR $HOST_BIN"
  _add_warning "residual neovim node-host files after removal"
fi
