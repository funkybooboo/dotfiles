# 000202-mise.sh — mise polyglot runtime manager (node, python, go, rust, …)
# Installs: mise
# Links:    ~/.config/mise/config.toml
# Enables:  —
# Note: mise manages all language runtimes (node, python, go, rust, zig, bun).
#       System pacman packages for those languages are NOT installed — mise
#       owns them. 'mise install' provisions everything pinned in config.toml.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "mise"

install_aur mise
link_file "$DOTFILES_HOME/.config/mise/config.toml" "$HOME/.config/mise/config.toml"

if command -v mise &>/dev/null; then
  info "installing mise-managed runtimes (node, python, go, rust, zig, bun)..."
  mise install
  ok "mise tools installed"
else
  warn "mise not found — skipping runtime install"
  _add_warning "mise not found; run 'mise install' manually"
fi
