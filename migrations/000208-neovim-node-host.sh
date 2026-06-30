# 000208-neovim-node-host.sh — Neovim Node.js provider host
# Installs: the "neovim" npm package (provides neovim-node-host)
# Links:    —
# Enables:  —
# Note: ~/.config/nvim/lua/config/options.lua sets
#         g:node_host_prog = ~/.local/bin/neovim-node-host
#         NODE_PATH        = ~/.local/lib/node_modules
#       but never actually installed the package, so :checkhealth vim.provider
#       errored with "Failed to run: node .../neovim-node-host --version".
#       This migration provisions it: a global-prefix npm install into ~/.local
#       puts the host bin at ~/.local/bin/neovim-node-host (a symlink into
#       ~/.local/lib/node_modules/neovim) — matching both settings above.
#
#       Runs AFTER 000202-mise (which provisions node/npm via mise) so that npm
#       is available. npm is discovered from PATH first (the user's shell
#       activates mise), then from the mise shims dir as a fallback for the
#       non-interactive migrate.sh context.
#
#       Idempotent: skips when the host already exists and runs. Re-running
#       `npm install -g` is safe anyway, but we avoid the network hit.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "neovim node host"

HOST_BIN="$HOME/.local/bin/neovim-node-host"

# Resolve an executable (npm/node): prefer PATH, fall back to mise shims
# (available after 000202-mise runs `mise install`). migrate.sh runs in a
# non-interactive shell where mise may not be activated, so the shim dir is
# the reliable source on a fresh install.
resolve_cmd() {
  local _name="$1"
  if command -v "$_name" &>/dev/null; then
    command -v "$_name"
    return 0
  fi
  local _shim="$HOME/.local/share/mise/shims/$_name"
  if [[ -x "$_shim" ]]; then
    echo "$_shim"
    return 0
  fi
  return 1
}

# Verify the host runs. `node <host> --version` prints the neovim npm package
# version (e.g. 5.4.0) when healthy. Returns the version on stdout.
host_version() {
  local _node
  if ! _node="$(resolve_cmd node)"; then
    return 1
  fi
  "$_node" "$HOST_BIN" --version 2>/dev/null
}

# Already installed and functional?
if [[ -x "$HOST_BIN" ]] && _ver="$(host_version)"; then
  skip "neovim-node-host (already installed: $_ver)"
else
  if ! NPM="$(resolve_cmd npm)"; then
    warn "npm not found — cannot install neovim-node-host"
    warn "install node via mise ('mise install') then re-run, or run:"
    warn "  npm install -g --prefix ~/.local neovim"
    _add_warning "npm not available; neovim Node.js provider not installed"
  else
    info "installing neovim npm package (provides neovim-node-host) → ~/.local"
    # Global-prefix install into ~/.local: bin → ~/.local/bin, module →
    # ~/.local/lib/node_modules — exactly what options.lua expects.
    if "$NPM" install -g --prefix "$HOME/.local" neovim; then
      if [[ -x "$HOST_BIN" ]] && _ver="$(host_version)"; then
        ok "neovim-node-host installed: $_ver"
      elif [[ -x "$HOST_BIN" ]]; then
        # Bin exists but node could not be resolved to verify (e.g. node
        # shim missing). Treat as success-with-caveat rather than failure.
        ok "neovim-node-host installed at $HOST_BIN (could not verify version — node not on PATH)"
      else
        warn "install reported success but host bin missing: $HOST_BIN"
        _add_warning "neovim-node-host install reported success but bin missing; check node/npm"
      fi
    else
      warn "npm install failed for neovim package"
      _add_warning "npm install -g neovim failed; neovim Node.js provider not installed"
    fi
  fi
fi
