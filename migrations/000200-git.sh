# 000200-git.sh -- git + GitHub CLI + diff pagers + config + hooks
# Installs: git github-cli git-filter-repo git-lfs git-delta diffnav
# Links:    ~/.gitconfig
# Enables:  --
# Note: core.pager is nvimpager (installed by 000108-neovim.sh); diffnav is
#       only pager.diff, and git-delta is interactive.diffFilter (git add -p).
#       Do not promote diffnav to core.pager -- its bubbletea TUI leaks
#       terminal query replies into the shell on short output. git-lfs is
#       referenced by [filter "lfs"].
#       Sets core.hooksPath to .githooks for pre-commit secret scanning.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "git"

install_pacman git github-cli git-filter-repo git-lfs git-delta diffnav

link_file "$DOTFILES_HOME/.gitconfig" "$HOME/.gitconfig"

# Set git hooks path so pre-commit secret scanning is active
if [[ -d "$REPO_ROOT/.githooks" ]]; then
  git config core.hooksPath .githooks
  ok "git hooks path set to .githooks (pre-commit secret scanning active)"
fi
