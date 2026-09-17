# 000108-neovim.sh -- Neovim + plugin tooling + config
# Installs: neovim tree-sitter-cli stylua luarocks lua51 python-pynvim
#           tectonic (pacman) nvimpager (via nix -- .#nvimpager)
# Links:    ~/.config/nvim/**, ~/.config/nvimpager/init.lua, ~/.editorconfig
# Enables:  --
# Note: tectonic provides LaTeX for the nvim latex plugin. nvimpager is the
#       PAGER/MANPAGER set in environment-variables. lua51 + luarocks +
#       stylua + tree-sitter-cli support nvim plugins.
#       nvimpager is installed from nixpkgs -- hermetic, sandboxed build,
#       no pkgbuilds/ needed.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "neovim"

install_pacman \
  neovim tree-sitter-cli stylua luarocks lua51 \
  python-pynvim tectonic
# nvimpager: installed from nixpkgs.
install_nix .#nvimpager
ok "neovim + tooling"

link_tree "$DOTFILES_HOME/.config/nvim" "$HOME/.config/nvim"
link_file "$DOTFILES_HOME/.config/nvimpager/init.lua" "$HOME/.config/nvimpager/init.lua"
link_file "$DOTFILES_HOME/.editorconfig" "$HOME/.editorconfig"

# The 99 plugin is loaded in place from the sources/99 submodule (initialized in
# preflight). Non-fatal, but nvim errors on :lazy load without it.
if source_ready 99; then
  ok "99 plugin source (submodule sources/99)"
fi
