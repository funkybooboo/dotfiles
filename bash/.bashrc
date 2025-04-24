export PATH="$HOME/.local/bin:$PATH"

dotfiles() {
    /usr/bin/env git --git-dir="$HOME/dotfiles/.git" --work-tree="$HOME/dotfiles" "$@"
}

if [[ -f "$HOME/.cargo/env" ]]; then
    source "$HOME/.cargo/env"
fi
