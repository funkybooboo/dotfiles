# 000523-proton-pass.sh — Proton Pass CLI + GUI + bash completions
# Installs (AUR): proton-pass-cli-bin proton-pass-bin
# Links:    — (completions generated at runtime below)
# Enables:  —
# Note: The interactive pass-cli LOGIN is deferred to setup-secrets.sh (needs a
#       browser + desktop). This migration only installs + sets up completions.
#       Requires yay (installed by 000001-system-update); if yay is missing it
#       warns and skips rather than piping a remote script to a shell.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "proton pass"

if ! command -v yay &>/dev/null; then
  warn "yay not available — cannot install Proton Pass packages"
  _add_warning "yay missing; install proton-pass-cli-bin and proton-pass-bin manually via yay"
else
  # Proton Pass CLI
  if command -v pass-cli &>/dev/null; then
    skip "pass-cli (already installed)"
  else
    install_aur proton-pass-cli-bin
  fi

  # Proton Pass GUI
  if command -v proton-pass &>/dev/null; then
    skip "proton-pass GUI (already installed)"
  else
    install_aur proton-pass-bin
  fi
fi

# Bash completions for pass-cli (the active login shell during migration).
# fish completions are handled by fish's own config tree (000101-fish).
if command -v pass-cli &>/dev/null; then
  COMPL_FILE="$HOME/.local/share/bash-completion/completions/pass-cli"
  mkdir -p "$HOME/.local/share/bash-completion/completions"
  if [[ ! -f "$COMPL_FILE" ]]; then
    pass-cli completions bash > "$COMPL_FILE" 2>/dev/null || true
    ok "bash completions for pass-cli installed"
  else
    skip "bash completions for pass-cli (already present)"
  fi
fi
