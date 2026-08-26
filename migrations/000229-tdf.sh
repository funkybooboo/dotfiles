# 000229-tdf.sh -- tdf (nix flake)
# Nix:     .#tdf
# Links:   ~/.local/share/applications/tdf.desktop
# Enables: --
# Note: one piece of software = one migration. tdf ships no upstream Linux
#       release tarball, so the nix flake is the cleanest prebuilt path
#       (hermetic, sandboxed, PR-reviewed). Split out of the former
#       000210-cli-utilities grab-bag.
#       tdf is a TUI (no GUI), so the nix package ships only the binary --
#       no .desktop. Without one, the `application/pdf=tdf.desktop` entry in
#       ~/.config/mimeapps.list fails to resolve and xdg-mime falls back to
#       chromium. We ship our own tdf.desktop that wraps `ghostty -e tdf %f`
#       (ghostty is the configured terminal, see x-scheme-handler/terminal in
#       mimeapps.list) so the existing PDF default actually takes effect.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "tdf"

install_nix .#tdf

# Desktop entry so mimeapps.list's application/pdf=tdf.desktop resolves.
# ~/.local/share/applications precedes /usr/share, so this wins over any
# packaged stub. tdf is a TUI -> we launch it under ghostty.
link_file "$DOTFILES_HOME/.local/share/applications/tdf.desktop" \
  "$HOME/.local/share/applications/tdf.desktop"

# Refresh the user desktop database so xdg-mime / launchers pick it up.
# Non-fatal: update-desktop-database may be absent on a minimal install.
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
fi

ok "tdf"
