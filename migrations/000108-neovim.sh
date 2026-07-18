# 000108-neovim.sh — Neovim + plugin tooling + config
# Installs: neovim tree-sitter-cli stylua luarocks lua51 python-pynvim
#           tectonic (pacman) nvimpager (via nix — nixpkgs#nvimpager)
# Links:    ~/.config/nvim/**, ~/.editorconfig
# Enables:  —
# Note: tectonic provides LaTeX for the nvim latex plugin. nvimpager is the
#       PAGER/MANPAGER set in environment-variables. lua51 + luarocks +
#       stylua + tree-sitter-cli support nvim plugins.
#       nvimpager is installed from nixpkgs — hermetic, sandboxed build,
#       no pkgbuilds/ needed.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "neovim"

install_pacman \
  neovim tree-sitter-cli stylua luarocks lua51 \
  python-pynvim tectonic
# nvimpager: installed from nixpkgs.
install_nix nixpkgs#nvimpager
ok "neovim + tooling"

link_tree "$DOTFILES_HOME/.config/nvim" "$HOME/.config/nvim"
link_file "$DOTFILES_HOME/.editorconfig" "$HOME/.editorconfig"

# The 99 plugin lives in the dotfiles git submodule sources/99 (initialized in
# preflight via `git submodule update --init --recursive`). Verify it is
# populated; if not, warn and let the user run migrate again / submodule init.
NINES_DIR="$REPO_ROOT/sources/99"
# A submodule checkout has a `.git` FILE (gitlink), not a dir -- use -e.
if [[ -e "$NINES_DIR/.git" ]]; then
  ok "99 plugin source (submodule sources/99)"
else
  warn "sources/99 submodule not populated — nvim will error on :lazy load"
  _add_warning "sources/99 submodule missing; run 'git -C ~/dotfiles submodule update --init sources/99'"
fi
