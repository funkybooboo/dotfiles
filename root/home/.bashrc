#
# ~/.bashrc
#

export EDITOR=nvim
export VISUAL=nvim
export PAGER=nvimpager
export MANPAGER=nvimpager
export BROWSER=librewolf
export SUDO_EDITOR="$EDITOR"
export BAT_THEME="Catppuccin Mocha"
export MANROFFOPT="-c"
export LESSHISTFILE=-
export PYTHONSTARTUP="${XDG_CONFIG_HOME:-$HOME/.config}/python/pythonrc"

# History
shopt -s histappend
HISTCONTROL=ignoreboth
HISTSIZE=32768
HISTFILESIZE="${HISTSIZE}"

# Completion
if [[ ! -v BASH_COMPLETION_VERSINFO && -f /usr/share/bash-completion/bash_completion ]]; then
    source /usr/share/bash-completion/bash_completion
fi

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# eza
if command -v eza &>/dev/null; then
    alias ls='eza --group-directories-first --icons=auto'
    alias l='eza -lh --group-directories-first --icons=auto'
    alias la='l -a'
    alias lt='eza --tree --level=2 --long --icons --git'
    alias lta='lt -a'
fi

# media
alias ffmpeg='ffmpeg -hide_banner'
alias yt-dlp='yt-dlp --embed-metadata --restrict-filenames -i'
alias yt-music='yt-dlp -x --audio-quality 0 --embed-thumbnail -o "%(title)s.%(ext)s"'

# git
alias g='git'
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gcad='git commit -a --amend'
alias gd='git diff'
alias gs='git status'
alias gl='git log --oneline -20'
alias gco='git checkout'
alias gb='git branch'

# navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# tools
alias c='opencode'
alias d='docker'
alias t='tmux attach || tmux new -s Work'

# functions
n() { if [ "$#" -eq 0 ]; then command nvim . ; else command nvim "$@"; fi; }

open() {
    xdg-open "$@" >/dev/null 2>&1 &
    disown
}

compress() { tar -czf "${1%/}.tar.gz" "${1%/}"; }
alias decompress='tar -xzf'

# zoxide
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init bash)"
fi

# mise
if command -v mise &>/dev/null; then
    eval "$(mise activate bash)"
fi

# starship
if [[ $- == *i* ]] && [[ ${TERM:-} != "dumb" ]] && command -v starship &>/dev/null; then
    eval "$(starship init bash)"
fi

# atuin
if command -v atuin &>/dev/null; then
    eval "$(atuin init bash --disable-up-arrow)"
fi

# fzf
if command -v fzf &>/dev/null; then
    # Catppuccin Mocha fzf colors
    export FZF_DEFAULT_OPTS="\
        --height 40% \
        --layout=reverse \
        --border \
        --prompt='❯ ' \
        --pointer='▶' \
        --color=bg:#1e1e2e,bg+:#313244,fg:#cdd6f4,fg+:#cdd6f4 \
        --color=hl:#f38ba8,hl+:#f38ba8,header:#f38ba8 \
        --color=info:#cba6f7,prompt:#cba6f7,pointer:#f5e0dc \
        --color=marker:#a6e3a1,spinner:#f5e0dc,border:#45475a"
    if [[ -f /usr/share/fzf/completion.bash ]]; then
        source /usr/share/fzf/completion.bash
    fi
    if [[ -f /usr/share/fzf/key-bindings.bash ]]; then
        source /usr/share/fzf/key-bindings.bash
    fi
fi
# mise activates bash with all runtime paths (node, python, go, rust, etc.)
# No hardcoded PATH entries needed
