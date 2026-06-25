# 000109-vim.sh — vimrc (no install — neovim reads it; vim not installed)
# Installs: —
# Links:    ~/.vimrc
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "vim"

link_file "$DOTFILES_HOME/.vimrc" "$HOME/.vimrc"
