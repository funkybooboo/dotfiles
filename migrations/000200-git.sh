# 000200-git.sh -- git + GitHub CLI + diff pagers + config + hooks
# Installs: git github-cli git-filter-repo git-lfs git-delta diffnav
# Links:    ~/.gitconfig
# Enables:  --
# Note: git-delta (interactive.diffFilter) and diffnav (core.pager) are the diff
#       pagers referenced in .gitconfig. git-lfs is referenced by [filter "lfs"].
#       Sets core.hooksPath to .githooks for pre-commit secret scanning.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "git"

if is_debian; then
  install_apt git git-lfs git-delta git-filter-repo gh
  # diffnav has no Debian package; delta is the core diff pager.
  _add_warning "diffnav: install manually on Debian (delta remains the core pager)"
  info "diffnav: not available in apt -- delta is the core diff pager"
else
  install_pacman git github-cli git-filter-repo git-lfs git-delta diffnav
fi

link_file "$DOTFILES_HOME/.gitconfig" "$HOME/.gitconfig"

# Set git hooks path so pre-commit secret scanning is active
if [[ -d "$REPO_ROOT/.githooks" ]]; then
  git config core.hooksPath .githooks
  ok "git hooks path set to .githooks (pre-commit secret scanning active)"
fi
