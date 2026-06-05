# 22-proton-pass.sh — Proton Pass CLI + GUI + login

section "Proton Pass & Secrets"

# Install Proton Pass CLI
if command -v pass-cli &>/dev/null; then
  skip "pass-cli (already installed)"
elif [[ $DRY_RUN -eq 1 ]]; then
  info "would install: pass-cli (proton-pass-cli-bin)"
else
  info "Installing Proton Pass CLI..."
  if command -v yay &>/dev/null; then
    yay -S --needed --noconfirm proton-pass-cli-bin 2>/dev/null || \
      { info "AUR install failed, using official script..."; curl -fsSL https://proton.me/download/pass-cli/install.sh | bash; }
  else
    curl -fsSL https://proton.me/download/pass-cli/install.sh | bash
  fi
  ok "pass-cli installed"
fi

# Install Proton Pass GUI
if command -v proton-pass &>/dev/null || flatpak list 2>/dev/null | grep -qi proton-pass; then
  skip "proton-pass GUI (already installed)"
elif [[ $DRY_RUN -eq 1 ]]; then
  info "would install: proton-pass GUI (proton-pass-bin)"
else
  info "Installing Proton Pass GUI..."
  if command -v yay &>/dev/null; then
    yay -S --needed --noconfirm proton-pass-bin
    ok "proton-pass GUI installed"
  else
    warn "Install proton-pass GUI manually from https://proton.me/pass/download/linux"
  fi
fi

# Install shell completions for pass-cli
if [[ $DRY_RUN -eq 0 ]] && command -v pass-cli &>/dev/null; then
  SHELL_NAME="${SHELL##*/}"
  case "$SHELL_NAME" in
    bash)
      COMPL_FILE="$HOME/.local/share/bash-completion/completions/pass-cli"
      mkdir -p "$HOME/.local/share/bash-completion/completions"
      if [[ ! -f "$COMPL_FILE" ]]; then
        pass-cli completions bash > "$COMPL_FILE" 2>/dev/null || true
        ok "bash completions for pass-cli installed"
      else
        skip "bash completions for pass-cli (already present)"
      fi
      ;;
    zsh)
      COMPL_FILE="$HOME/.zfunc/_pass-cli"
      mkdir -p "$HOME/.zfunc"
      if [[ ! -f "$COMPL_FILE" ]]; then
        pass-cli completions zsh > "$COMPL_FILE" 2>/dev/null || true
        ok "zsh completions for pass-cli installed"
      else
        skip "zsh completions for pass-cli (already present)"
      fi
      ;;
    fish)
      COMPL_FILE="$HOME/.config/fish/completions/pass-cli.fish"
      mkdir -p "$HOME/.config/fish/completions"
      if [[ ! -f "$COMPL_FILE" ]]; then
        pass-cli completions fish > "$COMPL_FILE" 2>/dev/null || true
        ok "fish completions for pass-cli installed"
      else
        skip "fish completions for pass-cli (already present)"
      fi
      ;;
  esac
fi

# Proton Pass login (interactive)
if [[ $DRY_RUN -eq 0 ]]; then
  if pass-cli info &>/dev/null 2>&1; then
    skip "Proton Pass (already logged in)"
  else
    echo ""
    info "Proton Pass login required — opening browser for authentication..."
    echo -e "  ${DIM}After completing login in the browser, press Enter to continue.${NC}"
    pass-cli login
    ok "Proton Pass logged in"
  fi
fi

# secretmgr bootstrap is deferred to install.sh (needs symlinked configs)