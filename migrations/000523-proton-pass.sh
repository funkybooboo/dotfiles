# 000523-proton-pass.sh — Proton Pass CLI + GUI + shell completions
# Installs: proton-pass-cli-bin proton-pass-bin
# Links:    — (completions generated at runtime below)
# Enables:  —
# Note: The interactive pass-cli LOGIN is deferred to setup-secrets.sh (needs a
#       browser + desktop). This migration only installs + sets up completions.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "proton pass"

# Proton Pass CLI
if command -v pass-cli &>/dev/null; then
  skip "pass-cli (already installed)"
else
  info "Installing Proton Pass CLI..."
  if command -v yay &>/dev/null; then
    install_aur proton-pass-cli-bin
  else
    _pp_installer=$(mktemp)
    if curl -fsSL https://proton.me/download/pass-cli/install.sh -o "$_pp_installer"; then
      bash "$_pp_installer"
    else
      warn "failed to download pass-cli installer"
      _add_warning "pass-cli install failed; run the installer manually"
    fi
    rm -f "$_pp_installer"
  fi
  ok "pass-cli installed"
fi

# Proton Pass GUI
if command -v proton-pass &>/dev/null || flatpak list 2>/dev/null | grep -qi proton-pass; then
  skip "proton-pass GUI (already installed)"
else
  info "Installing Proton Pass GUI..."
  if command -v yay &>/dev/null; then
    install_aur proton-pass-bin
  else
    warn "Install proton-pass GUI manually from https://proton.me/pass/download/linux"
    _add_warning "proton-pass GUI not installed — install manually"
  fi
fi

# Shell completions for pass-cli
if command -v pass-cli &>/dev/null; then
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
  esac
fi
