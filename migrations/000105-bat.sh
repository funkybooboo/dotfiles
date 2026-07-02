# 000105-bat.sh -- bat (cat clone with syntax highlighting)
# Installs: bat
# Links:    ~/.config/bat/**
# Enables:  --
# Note: Includes a Catppuccin Mocha theme under themes/. bat requires
#       `bat cache --build` to register custom themes, so that runs after
#       linking. The active theme is set via --theme in config.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "bat"

if is_debian; then
  install_apt bat
  # On Debian/Ubuntu, bat installs as 'batcat'; add a ~/.local/bin/bat shim.
  if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
    ok "bat -> batcat symlink created in ~/.local/bin"
  fi
else
  install_pacman bat
fi
link_tree "$DOTFILES_HOME/.config/bat" "$HOME/.config/bat"

# Register custom themes (e.g. Catppuccin Mocha) so --theme resolves.
if command -v bat &>/dev/null; then
  bat cache --build >/dev/null 2>&1 || warn "bat cache --build failed"
  ok "bat cache built"
else
  warn "bat not found -- skipping cache build"
  _add_warning "bat not found; run 'bat cache --build' manually"
fi
