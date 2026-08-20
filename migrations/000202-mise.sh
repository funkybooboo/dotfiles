# 000202-mise.sh -- mise polyglot runtime manager (node, python, go, rust, ...)
# Installs: mise (now in extra/ -- official Arch package)
# Links:    ~/.config/mise/config.toml
# Enables:  --
# Note: mise manages all language runtimes (node, python, go, rust, zig, bun).
#       System pacman packages for those languages are NOT installed -- mise
#       owns them. 'mise install' provisions everything pinned in config.toml.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "mise"

if is_debian; then
  # mise is NOT in the Ubuntu archive -- it ships its own signed apt repo.
  # add_apt_repo is idempotent and pins the key with signed-by.
  add_apt_repo \
    "https://mise.jdx.dev/gpg-key.pub" \
    "/etc/apt/keyrings/mise-archive-keyring.gpg" \
    "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=amd64] https://mise.jdx.dev/deb stable main" \
    "mise"
  install_apt mise
else
  install_pacman mise
fi
link_file "$DOTFILES_HOME/.config/mise/config.toml" "$HOME/.config/mise/config.toml"

if command -v mise &>/dev/null; then
  info "installing mise-managed runtimes (node, python, go, rust, zig, bun)..."
  mise install
  ok "mise tools installed"
else
  warn "mise not found -- skipping runtime install"
  _add_warning "mise not found; run 'mise install' manually"
fi
