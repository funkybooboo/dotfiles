# 000209-mermaid-cli.sh — Mermaid CLI (mmdc) for Snacks.image diagram rendering
# Installs: the "@mermaid-js/mermaid-cli" npm package (provides mmdc)
# Links:    — (env vars live in ~/.config/environment.d/apps.conf, deployed by
#            000319-xdg.sh)
# Enables:  —
# Note: Snacks.image renders Mermaid code blocks in docs/markdown by shelling
#       out to `mmdc`. Without it, :checkhealth snacks reports
#       "❌ ERROR Tool not found: 'mmdc'".
#
#       mmdc drives puppeteer, which by default downloads its own ~150MB
#       Chromium at install time. We skip that (PUPPETEER_SKIP_DOWNLOAD=1,
#       set in apps.conf) and point puppeteer at the SYSTEM chromium
#       (PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium), which 000303-browsers.sh
#       installs. mmdc only needs chromium at *runtime* (when nvim renders a
#       diagram inside the graphical session), well after all migrations have
#       finished, so the 000303-vs-000209 ordering does not matter.
#
#       Runs AFTER 000202-mise (node/npm provider) and alongside 000208-neovim-
#       node-host. npm/node are resolved via PATH then mise shims, matching
#       000208. Idempotent: skips when mmdc already runs.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "mermaid cli"

MMDC_BIN="$HOME/.local/bin/mmdc"
PKG="@mermaid-js/mermaid-cli"

# Resolve an executable (npm/node): prefer PATH, fall back to mise shims
# (available after 000202-mise runs `mise install`). migrate.sh runs in a
# non-interactive shell where mise may not be activated.
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

# Verify mmdc runs. Prints its version on stdout.
mmdc_version() {
  local _node
  if ! _node="$(resolve_cmd node)"; then
    return 1
  fi
  "$_node" "$MMDC_BIN" --version 2>/dev/null
}

# Already installed and functional?
if [[ -x "$MMDC_BIN" ]] && _ver="$(mmdc_version)"; then
  skip "mmdc (already installed: $_ver)"
else
  if ! NPM="$(resolve_cmd npm)"; then
    warn "npm not found — cannot install mmdc"
    warn "install node via mise ('mise install') then re-run, or run:"
    warn "  PUPPETEER_SKIP_DOWNLOAD=1 npm install -g --prefix ~/.local @mermaid-js/mermaid-cli"
    _add_warning "npm not available; mermaid-cli (mmdc) not installed"
  else
    info "installing mermaid-cli (provides mmdc) → ~/.local"
    # Skip puppeteer's bundled Chromium download; we use the system chromium
    # via PUPPETEER_EXECUTABLE_PATH (set in apps.conf by 000319-xdg.sh).
    if PUPPETEER_SKIP_DOWNLOAD=1 "$NPM" install -g --prefix "$HOME/.local" "$PKG"; then
      if [[ -x "$MMDC_BIN" ]] && _ver="$(mmdc_version)"; then
        ok "mmdc installed: $_ver"
      elif [[ -x "$MMDC_BIN" ]]; then
        ok "mmdc installed at $MMDC_BIN (could not verify version — node not on PATH)"
      else
        warn "install reported success but mmdc bin missing: $MMDC_BIN"
        _add_warning "mmdc install reported success but bin missing; check node/npm"
      fi
    else
      warn "npm install failed for $PKG"
      _add_warning "npm install -g $PKG failed; mermaid-cli (mmdc) not installed"
    fi
  fi
fi
