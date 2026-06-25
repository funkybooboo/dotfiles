# 000200-git.sh — git + GitHub CLI + diff pagers + config + hooks
# Installs: git github-cli git-filter-repo git-lfs git-delta diffnav
# Links:    ~/.gitconfig
# Enables:  —
# Note: git-delta (interactive.diffFilter) and diffnav (core.pager) are the diff
#       pagers referenced in .gitconfig. git-lfs is referenced by [filter "lfs"].
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
