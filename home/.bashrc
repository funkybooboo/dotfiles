# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# ============================================================================
# BLE.SH - Fish-like features (must load early!)
# ============================================================================
# Load ble.sh for Fish-like autosuggestions, syntax highlighting, and enhanced completion
if [ -f ~/.local/share/blesh/ble.sh ]; then
  source ~/.local/share/blesh/ble.sh --noattach
fi

# Prevent multiple sourcing
if [ -n "$__bashrc_sourced" ]; then
  return
fi
export __bashrc_sourced=1

# ============================================================================
# OMARCHY DEFAULTS
# ============================================================================
# Load Omarchy default bash configuration (if available)
if [ -f ~/.local/share/omarchy/default/bash/rc ]; then
  source ~/.local/share/omarchy/default/bash/rc
fi

# ============================================================================
# HISTORY CONFIGURATION
# ============================================================================
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend
HISTSIZE=10000
HISTFILESIZE=20000
HISTTIMEFORMAT="%F %T "
PROMPT_COMMAND="history -a; history -n; ${PROMPT_COMMAND}"

# ============================================================================
# SHELL OPTIONS
# ============================================================================
shopt -s checkwinsize  # Update LINES and COLUMNS after each command
shopt -s globstar      # Enable ** recursive globbing
shopt -s cdspell       # Correct minor directory spelling errors
shopt -s dirspell      # Correct directory spelling in completion
shopt -s extglob       # Enable extended pattern matching
shopt -s nocaseglob    # Case-insensitive globbing

# ============================================================================
# ENVIRONMENT VARIABLES
# ============================================================================
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"
export LESS="-R"
export PYENV_ROOT="$HOME/.pyenv"
export BUN_INSTALL="$HOME/.bun"
export LIBVIRT_DEFAULT_URI="qemu:///system"

# ============================================================================
# PATH CONFIGURATION
# ============================================================================
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

# Flatpak exports
__add_to_path_if_exists "/var/lib/flatpak/exports/share"
__add_to_path_if_exists "$HOME/.local/share/flatpak/exports/share"

__add_to_path_if_exists "$HOME/.cargo/bin"
__add_to_path_if_exists "$HOME/go/bin"
__add_to_path_if_exists "$HOME/.nix-profile/bin"
__add_to_path_if_exists "/nix/var/nix/profiles/default/bin"
__add_to_path_if_exists "$PYENV_ROOT/bin"
__add_to_path_if_exists "$HOME/.asdf/shims"
__add_to_path_if_exists "$BUN_INSTALL/bin"

# ============================================================================
# MODERN TOOL ALIASES (conditional - only if installed)
# ============================================================================
command -v eza &> /dev/null && alias ls='eza --icons'
command -v fd &> /dev/null && alias find='fd'
command -v fdfind &> /dev/null && alias fd='fdfind'
command -v mtr &> /dev/null && alias ping='mtr --report --report-cycles 1'
command -v procs &> /dev/null && alias ps='procs'
command -v bat &> /dev/null && alias cat='bat'
command -v batcat &> /dev/null && alias bat='batcat'
command -v glances &> /dev/null && alias htop='glances'
command -v duf &> /dev/null && alias df='duf'

# ============================================================================
# CUSTOM ALIASES
# ============================================================================
# Editor aliases
alias vim="nvim"
alias vi="nvim"

# System monitoring
alias htop="btop"
alias top="btop"

# Listing
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias code='codium'

# Utilities
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Server aliases
alias raspberrypi_server='ssh nate@raspberrypi.lan' # raspberry pi 4
alias dimension_server='ssh nate@192.168.8.210' # old desktop from di
alias tnas_server='ssh funkybooboo@nas.lan' # my nas
alias middlechild_server='ssh root@middlechild.cloud' # digital ocean vm
alias cs6715_server='ssh cs6715@192.168.8.208' # on a local vm

# Source bash aliases if they exist
if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

# ============================================================================
# FUNCTIONS
# ============================================================================

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

# ============================================================================
# TOOL INITIALIZATION
# ============================================================================

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

# -------------------------------
# SSH agent setup with KWallet integration
# -------------------------------
# Use persistent ssh-agent from systemd service
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

# Configure SSH to use ksshaskpass for passphrase prompts (integrates with KWallet)
export SSH_ASKPASS="/usr/bin/ksshaskpass"
export SSH_ASKPASS_REQUIRE=prefer

# Add ED25519 key if not already added
if [[ -f "$HOME/.ssh/id_ed25519" ]]; then
  ssh-add -l >/dev/null 2>&1 || {
    # Key not loaded, add it (will use ksshaskpass/KWallet for passphrase)
    ssh-add "$HOME/.ssh/id_ed25519" </dev/null >/dev/null 2>&1
  }
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

# Bash completion
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

# ============================================================================
# BLE.SH ATTACH (must be at the end!)
# ============================================================================
# Attach ble.sh after all other initialization
if [[ ${BLE_VERSION-} ]]; then
  ble-attach
fi

export GPG_TTY=$(tty)

