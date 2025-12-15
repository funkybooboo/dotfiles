# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

# Prevent multiple sourcing
if [ -n "$__bashrc_sourced" ]; then
  return
fi
export __bashrc_sourced=1

# ===== History Configuration =====
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend
HISTSIZE=10000
HISTFILESIZE=20000
HISTTIMEFORMAT="%F %T "
PROMPT_COMMAND="history -a; history -n; ${PROMPT_COMMAND}"

# ===== Shell Options =====
shopt -s checkwinsize  # Update LINES and COLUMNS after each command
shopt -s globstar      # Enable ** recursive globbing
shopt -s cdspell       # Correct minor directory spelling errors
shopt -s dirspell      # Correct directory spelling in completion
shopt -s extglob       # Enable extended pattern matching
shopt -s nocaseglob    # Case-insensitive globbing

# ===== Less Configuration =====
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# ===== Prompt Configuration =====
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
  debian_chroot=$(cat /etc/debian_chroot)
fi

case "$TERM" in
xterm-color | *-256color) color_prompt=yes ;;
esac

if [ -n "$force_color_prompt" ]; then
  if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    color_prompt=yes
  else
    color_prompt=
  fi
fi

if [ "$color_prompt" = yes ]; then
  PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
  PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

case "$TERM" in
xterm* | rxvt*)
  PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
  ;;
*) ;;
esac

# ===== Color Support =====
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# ===== Environment Variables =====
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"
export LESS="-R"
export PYENV_ROOT="$HOME/.pyenv"
export BUN_INSTALL="$HOME/.bun"

# ===== PATH Configuration =====
# Helper function to add to PATH only if directory exists
__add_to_path_if_exists() {
  if [ -d "$1" ]; then
    case ":$PATH:" in
      *":$1:"*) ;;
      *) export PATH="$1:$PATH" ;;
    esac
  fi
}

# Add paths in order of priority
__add_to_path_if_exists "$HOME/.local/bin"

# Add all subdirectories in ~/.local/bin to PATH
if [ -d "$HOME/.local/bin" ]; then
  for dir in "$HOME/.local/bin"/*/ ; do
    [ -d "$dir" ] && __add_to_path_if_exists "$dir"
  done
fi

__add_to_path_if_exists "$HOME/.cargo/bin"
__add_to_path_if_exists "$HOME/go/bin"
__add_to_path_if_exists "$HOME/.nix-profile/bin"
__add_to_path_if_exists "/nix/var/nix/profiles/default/bin"
__add_to_path_if_exists "$PYENV_ROOT/bin"
__add_to_path_if_exists "$HOME/.asdf/shims"
__add_to_path_if_exists "$BUN_INSTALL/bin"

# ===== Conditional Aliases (only if command exists) =====
command -v eza &> /dev/null && alias ls='eza --icons'
command -v fd &> /dev/null && alias find='fd'
command -v fdfind &> /dev/null && alias fd='fdfind'
command -v mtr &> /dev/null && alias ping='mtr --report --report-cycles 1'
command -v procs &> /dev/null && alias ps='procs'
command -v bat &> /dev/null && alias cat='bat'
command -v batcat &> /dev/null && alias bat='batcat'
command -v glances &> /dev/null && alias htop='glances'
command -v duf &> /dev/null && alias df='duf'
command -v multipass &> /dev/null && alias mp='multipass'

# Traditional aliases (with fallbacks)
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# ===== Server Aliases =====
alias raspberrypi_server='ssh nate@raspberrypi.local'
alias dimension_server='ssh nate@192.168.0.134'
alias tnas_server='ssh funkybooboo@192.168.8.238'
alias middlechild_server='ssh root@139.59.173.228'

# ===== Bash Aliases =====
if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

# ===== Programmable Completion =====
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

if [ -f /usr/share/bash-completion/completions/git ]; then
  source /usr/share/bash-completion/completions/git
fi

# ===== Functions =====

# Dotfiles git function
dotfiles() {
  local dotfiles_dir="$HOME/dotfiles/.git"
  if [ -d "$dotfiles_dir" ]; then
    /usr/bin/env git --git-dir="$dotfiles_dir" --work-tree="$HOME/dotfiles" "$@"
  else
    echo "dotfiles directory not found: $dotfiles_dir" >&2
    return 1
  fi
}

# Yazi function with cwd change
if command -v yazi &> /dev/null; then
  y() {
    local tmp
    tmp=$(mktemp -t "yazi-cwd.XXXXXX")
    yazi "$@" --cwd-file="$tmp"
    if [ -f "$tmp" ]; then
      local cwd
      cwd=$(cat -- "$tmp")
      if [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd" || return
      fi
      rm -f -- "$tmp"
    fi
  }
fi

# Quick directory navigation
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Extract archives
extract() {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2)   tar xjf "$1"     ;;
      *.tar.gz)    tar xzf "$1"     ;;
      *.bz2)       bunzip2 "$1"     ;;
      *.rar)       unrar x "$1"     ;;
      *.gz)        gunzip "$1"      ;;
      *.tar)       tar xf "$1"      ;;
      *.tbz2)      tar xjf "$1"     ;;
      *.tgz)       tar xzf "$1"     ;;
      *.zip)       unzip "$1"       ;;
      *.Z)         uncompress "$1"  ;;
      *.7z)        7z x "$1"        ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Show command history stats
histstat() {
  history | awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | grep -v "./" | column -c3 -s " " -t | sort -nr | nl | head -n20
}

# Git helpers
gst() { git status "$@"; }
gco() { git checkout "$@"; }
gaa() { git add -A; }
gcm() { git commit -m "$@"; }
gp() { git push; }
gl() { git pull; }

# ===== Tool Initialization =====

# pyenv
if command -v pyenv &> /dev/null; then
  if [ -z "$PYENV_LOADED" ]; then
    export PYENV_LOADED=1
    eval "$(pyenv init -)"
  fi
fi

# fnm (Fast Node Manager)
if command -v fnm &> /dev/null; then
  eval "$(fnm env --use-on-cd)"
fi

# SSH agent setup
if [ -z "$SSH_AUTH_SOCK" ] || [ ! -S "$SSH_AUTH_SOCK" ]; then
  if ! pgrep -u "$(whoami)" ssh-agent >/dev/null; then
    eval "$(ssh-agent -s)" >/dev/null
  fi
fi

# Add SSH key if not already added
if [ -S "$SSH_AUTH_SOCK" ] && [ -f ~/.ssh/id_ed25519 ]; then
  ssh-add -l >/dev/null 2>&1 || ssh-add ~/.ssh/id_ed25519 2>/dev/null
fi

# Initialize jump if available
if command -v jump &> /dev/null; then
  eval "$(jump shell bash)"
  alias j='jump'
fi

# Initialize zoxide if available
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init bash)"
  alias cd='z'
fi

# Homebrew
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Cargo (Rust)
if [ -f "$HOME/.cargo/env" ]; then
  source "$HOME/.cargo/env"
fi

# asdf version manager
if [ -f "$HOME/.asdf/asdf.sh" ]; then
  source "$HOME/.asdf/asdf.sh"
  [ -f "$HOME/.asdf/completions/asdf.bash" ] && source "$HOME/.asdf/completions/asdf.bash"
fi

# fzf (fuzzy finder)
if command -v fzf &> /dev/null; then
  eval "$(fzf --bash)" 2>/dev/null || true
  export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"

  if command -v fd &> /dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  fi
fi

# direnv (auto-load environment variables)
if command -v direnv &> /dev/null; then
  eval "$(direnv hook bash)"
fi
