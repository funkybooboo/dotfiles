# 19-openviking.sh — OpenViking + Ollama models

section "OpenViking Setup"

info "installing OpenViking..."
if [[ $DRY_RUN -eq 1 ]]; then
  info "would install: openviking (via uv tool)"
else
  if ! command -v openviking-server &>/dev/null; then
    info "installing openviking via uv tool..."
    uv tool install openviking --force 2>&1 | tail -5 && ok "openviking installed" || warn "openviking install failed"
  else
    skip "openviking already installed"
  fi
fi

# Pull Ollama models for OpenViking (embedding + VLM)
if [[ $DRY_RUN -eq 1 ]]; then
  info "would pull: ollama models (nomic-embed-text, qwen3:4b)"
else
  if ! systemctl is-active --quiet ollama.service 2>/dev/null; then
    warn "ollama.service not running — start with: sudo systemctl start ollama"
    _add_warning "ollama not running — OpenViking will fail until ollama is started"
  else
    for model in nomic-embed-text qwen3:4b; do
      if ollama list 2>/dev/null | grep -q "$model"; then
        skip "ollama model $model (already pulled)"
      else
        info "pulling ollama model: $model..."
        if ollama pull "$model" 2>&1 | tail -3; then
          ok "ollama model $model pulled"
        else
          warn "failed to pull ollama model $model"
          _add_warning "ollama pull failed: $model"
        fi
      fi
    done
  fi
fi

# Plugin file check (will be symlinked later)
PLUGIN_FILE="$DOTFILES_HOME/.config/opencode/plugins/openviking-memory.ts"
if [[ -f "$PLUGIN_FILE" ]]; then
  skip "openviking-memory.ts (will be symlinked with dotfiles)"
fi

# Deploy OpenViking config if not present
OV_CONF_SRC="$DOTFILES_HOME/.openviking/ov.conf"
OV_CONF_DEST="$HOME/.openviking/ov.conf"
if [[ -f "$OV_CONF_SRC" ]]; then
  if [[ -f "$OV_CONF_DEST" ]] && cmp -s "$OV_CONF_SRC" "$OV_CONF_DEST"; then
    skip "ov.conf (already up to date)"
  elif [[ $DRY_RUN -eq 1 ]]; then
    if [[ -f "$OV_CONF_DEST" ]]; then
      skip "ov.conf (already exists)"
    else
      info "would install: ov.conf → $OV_CONF_DEST"
    fi
  else
    mkdir -p "$(dirname "$OV_CONF_DEST")"
    cp "$OV_CONF_SRC" "$OV_CONF_DEST"
    ok "ov.conf deployed"
  fi
fi