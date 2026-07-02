# 000210-cli-utilities.sh -- CLI utilities and dev tools (no config needed)
# Installs (pacman): fzf fd eza dust fastfetch jq wl-clipboard zoxide tree
#                    tealdeer unzip rsync ncdu inotify-tools ast-grep 7zip socat
#                    pandoc-cli (build dep for timg's manpage)
# Installs (AUR):    gum tdf timg lazydocker act
# Links:    --
# Enables:  --
# Note: pandoc-cli is installed BEFORE the AUR batch so that timg's PKGBUILD
#       can regenerate its manpage at build time. It is a somewhat heavy
#       (Haskell) dependency pulled in solely for that manpage.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "CLI utilities"

if is_debian; then
  install_apt \
    fzf fd-find du-dust eza jq wl-clipboard zoxide tree \
    tealdeer unzip rsync ncdu inotify-tools 7zip socat \
    pandoc gum timg
  # fd-find installs as 'fdfind' on Debian; add a ~/.local/bin/fd shim.
  if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
    ok "fd -> fdfind symlink created in ~/.local/bin"
  fi
  install_gh_release jesseduffield/lazydocker "Linux_x86_64" lazydocker
  install_gh_release nektos/act "Linux_x86_64" act
  # ast-grep and tdf are not in apt; install via cargo on Debian.
  _add_warning "ast-grep: install via cargo on Debian (cargo install ast-grep)"
  info "ast-grep: not in apt -- install with: cargo install ast-grep"
  _add_warning "tdf: install via cargo on Debian"
  info "tdf: not in apt -- install with: cargo install tdf"
else
  install_pacman \
    fzf fd eza dust fastfetch jq wl-clipboard zoxide tree \
    tealdeer unzip rsync ncdu inotify-tools ast-grep 7zip socat \
    pandoc-cli
  install_aur \
    gum tdf timg lazydocker act
fi

ok "CLI utilities"
