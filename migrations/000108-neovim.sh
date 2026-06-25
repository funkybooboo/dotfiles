# 000108-neovim.sh — Neovim + plugin tooling + config
# Installs: neovim nvimpager tree-sitter-cli stylua luarocks lua51
#           python-pynvim tectonic
# Links:    ~/.config/nvim/**, ~/.editorconfig
# Enables:  —
# Note: tectonic provides LaTeX for the nvim latex plugin. nvimpager is the
#       PAGER/MANPAGER set in environment-variables. lua51 + luarocks +
#       stylua + tree-sitter-cli support nvim plugins.
#       The 99 plugin (lua/plugins/99.lua) is developed locally and loaded via
#       dir = "~/sources/99"; it is cloned here from
#       github.com/funkybooboo/99.git (idempotent).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "neovim"

install_pacman \
  neovim nvimpager tree-sitter-cli stylua luarocks lua51 \
  python-pynvim
install_aur tectonic
ok "neovim + tooling"

link_tree "$DOTFILES_HOME/.config/nvim" "$HOME/.config/nvim"
link_file "$DOTFILES_HOME/.editorconfig" "$HOME/.editorconfig"

# Clone the local 99 plugin into ~/sources/99 (idempotent)
NINES_DIR="$HOME/sources/99"
if [[ -d "$NINES_DIR/.git" ]]; then
  skip "99 plugin repo (already cloned)"
else
  info "cloning 99 plugin → ~/sources/99..."
  mkdir -p "$HOME/sources"
  if git clone --quiet https://github.com/funkybooboo/99.git "$NINES_DIR"; then
    ok "99 plugin cloned"
  else
    warn "failed to clone 99 plugin — nvim will error on :lazy load until cloned"
    _add_warning "99 plugin clone failed; run 'git clone https://github.com/funkybooboo/99.git ~/sources/99'"
  fi
fi
