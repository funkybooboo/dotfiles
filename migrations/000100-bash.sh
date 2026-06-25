# 000100-bash.sh — bash shell dotfiles (no install — bash is in base)
# Installs: —
# Links:    ~/.bashrc, ~/.bash_profile, ~/.inputrc
# Enables:  —

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "bash"

link_file "$DOTFILES_HOME/.bashrc"       "$HOME/.bashrc"
link_file "$DOTFILES_HOME/.bash_profile" "$HOME/.bash_profile"
link_file "$DOTFILES_HOME/.inputrc"      "$HOME/.inputrc"
