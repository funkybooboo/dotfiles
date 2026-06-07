# 19-openviking.sh — OpenViking + Ollama

section "OpenViking Setup"

# Install uv (Python package runner) if not present
if command -v uv &>/dev/null; then
  skip "uv already installed"
elif [[ $DRY_RUN -eq 1 ]]; then
  info "would install: uv"
else
  info "installing uv..."
  sudo pacman -S --needed --noconfirm uv 2>/dev/null && ok "uv installed" || warn "failed to install uv"
fi

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

# Install and start Ollama for local LLM use (opencode)
if command -v ollama &>/dev/null; then
  skip "ollama already installed"
elif [[ $DRY_RUN -eq 1 ]]; then
  info "would install: ollama"
else
  info "installing ollama..."
  sudo pacman -S --needed --noconfirm ollama 2>/dev/null && ok "ollama installed" || warn "failed to install ollama"
  sudo systemctl enable --now ollama 2>/dev/null || warn "failed to start ollama.service"
fi

# Pull a small Qwen model for opencode local use
if [[ $DRY_RUN -eq 1 ]]; then
  info "would pull: ollama model qwen3:4b"
else
  if ! systemctl is-active --quiet ollama.service 2>/dev/null; then
    warn "ollama.service not running — start with: sudo systemctl start ollama"
    _add_warning "ollama not running — local model pull deferred"
  else
    if ollama list 2>/dev/null | grep -q "qwen3:4b"; then
      skip "ollama model qwen3:4b (already pulled)"
    else
      info "pulling ollama model: qwen3:4b..."
      if ollama pull qwen3:4b 2>&1 | tail -3; then
        ok "ollama model qwen3:4b pulled"
      else
        warn "failed to pull ollama model qwen3:4b"
        _add_warning "ollama pull failed: qwen3:4b"
      fi
    fi
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