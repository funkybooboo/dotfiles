# 000523-proton-pass.sh — Proton Pass CLI + GUI + bash completions
# Installs: proton-pass-cli (local PKGBUILD — Proton's official release binary)
# Flatpak:  me.proton.Pass (GUI, officially maintained by Proton)
# Links:    — (completions generated at runtime below)
# Enables:  —
# Note: The CLI is packaged locally from Proton's checksummed official release
#       binary (github.com/protonpass/pass-cli) — the local PKGBUILD's
#       replaces=proton-pass-cli-bin auto-removes the former AUR -bin on
#       install (same /usr/bin/pass-cli binary). The GUI comes from Flathub
#       (me.proton.Pass), replacing the former AUR proton-pass-bin.
#       The interactive pass-cli LOGIN is deferred to setup.sh (needs a
#       browser + desktop). This migration only installs + sets up
#       completions. Debug symbol packages are swept by 000550.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "proton pass"

# Proton Pass CLI — local PKGBUILD wrapping Proton's official release binary
# (replaces=proton-pass-cli-bin auto-removes the former AUR -bin on install).
install_local_pkgbuild proton-pass-cli

# Proton Pass GUI — official Flathub build, replacing the former AUR -bin.
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
