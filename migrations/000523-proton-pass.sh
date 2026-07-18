# 000523-proton-pass.sh — Proton Pass CLI + GUI + bash completions
# Nix:     .#proton-pass-cli (Proton's official release binary)
# Flatpak: me.proton.Pass (GUI, officially maintained by Proton)
# Links:   — (completions generated at runtime below)
# Enables: —
# Note: The CLI is installed from nix (via the local flake). The GUI comes
#       from Flathub (me.proton.Pass), Proton's official Linux distribution.
#       The interactive pass-cli LOGIN is deferred to setup.sh (needs a
#       browser + desktop). This migration only installs + sets up
#       completions.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "proton pass"

# Proton Pass CLI — from nix flake (Proton's official release binary).
install_nix .#proton-pass-cli

# Proton Pass GUI — official Flathub build.
install_flatpak me.proton.Pass
remove_pkg proton-pass-bin

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
