dotfiles() {
  /usr/bin/env git --git-dir="$HOME/dotfiles/" --work-tree="$HOME" "$@"
}
. "$HOME/.cargo/env"
