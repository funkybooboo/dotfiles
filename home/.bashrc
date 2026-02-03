# ~/.bashrc: executed by bash(1) for non-login shells.
#
# MINIMAL YET POWERFUL BASH CONFIGURATION
# ========================================
# Philosophy: Use tools as developers intended
#
# Features:
# ✓ Starship prompt (beautiful, git-aware)
# ✓ Zoxide (smart directory jumping: z, zi)
# ✓ Enhanced history (50k entries, smart search)
# ✓ Fuzzy finder (fzf: Ctrl+T, Ctrl+R, Alt+C)
# ✓ Auto-cd (type directory name to cd)
# ✓ Command timing (shows time for slow commands)
#
# Minimal aliases:
# • ls → eza (tasteful, simple)
# • code → codium (only if code doesn't exist)
# • .., ..., .... (parent directory shortcuts)
# • - (previous directory)
# • zi (zoxide interactive picker)
#
# Everything else: use real command names
# ========================================

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
# HISTORY CONFIGURATION (Fish-like infinite history)
# ============================================================================
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend
HISTSIZE=50000              # Increased for fish-like experience
HISTFILESIZE=100000         # Increased for fish-like experience
HISTTIMEFORMAT="%F %T "

# Fish-like history syncing across sessions
PROMPT_COMMAND="history -a; history -n; ${PROMPT_COMMAND}"

# ============================================================================
# SHELL OPTIONS (Fish-like features)
# ============================================================================
shopt -s checkwinsize  # Update LINES and COLUMNS after each command
shopt -s globstar      # Enable ** recursive globbing
shopt -s cdspell       # Correct minor directory spelling errors
shopt -s dirspell      # Correct directory spelling in completion
shopt -s extglob       # Enable extended pattern matching
shopt -s nocaseglob    # Case-insensitive globbing
shopt -s autocd        # Fish-like auto-cd: type directory name to cd into it
shopt -s cdable_vars   # If cd arg isn't a dir, try it as a variable
shopt -s direxpand     # Expand directory names on tab completion
shopt -s dotglob       # Include dotfiles in pathname expansion

# Enable vi mode for command line editing
set -o vi

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

# Ruby and Bundler
__add_to_path_if_exists "$HOME/.rbenv/bin"
__add_to_path_if_exists "$HOME/.rbenv/shims"

# RubyGems user install (version-agnostic)
if [ -d "$HOME/.local/share/gem/ruby" ]; then
  for ruby_dir in "$HOME/.local/share/gem/ruby"/*/bin; do
    [ -d "$ruby_dir" ] && __add_to_path_if_exists "$ruby_dir"
  done
fi

# Additional language package managers
__add_to_path_if_exists "$HOME/.deno/bin"
__add_to_path_if_exists "$HOME/.local/share/pnpm"
__add_to_path_if_exists "$HOME/.config/composer/vendor/bin"
__add_to_path_if_exists "/var/lib/snapd/snap/bin"

__add_to_path_if_exists "$HOME/.opencode/bin"

# ============================================================================
# ALIASES (minimal - tools as developers intended)
# ============================================================================
# Modern tool alternatives (use by their real names):
#   bat      - cat with syntax highlighting
#   fd       - faster find
#   btop     - better top/htop
#   procs    - better ps
#   dust     - better du (disk usage)
#   ripgrep  - faster grep (use: rg)
#   nvim     - modern vim
#   git      - use full commands (git status, git add, etc.)

# eza - tasteful ls replacement (keep it simple)
if command -v eza &> /dev/null; then
  alias ls='eza'                    # Simple list
  alias la='eza -a'                 # Simple list with hidden files
  alias ll='eza -la'                 # Long format (permissions, size, date, etc.)
fi

# VSCodium - only if code doesn't exist
if command -v codium &> /dev/null; then
  command -v code &> /dev/null || alias code='codium'
fi

if command -v go-task &> /dev/null; then
  command -v task &> /dev/null || alias task='go-task'
fi

# Server aliases
alias raspberrypi_server='ssh nate@raspberrypi.lan' # raspberry pi 4
alias dimension_server='ssh nate@192.168.8.210' # old desktop from di
alias tnas_server='ssh funkybooboo@nas.lan' # my nas
alias middlechild_server='ssh root@middlechild.cloud' # digital ocean vm
alias cs6715_server='ssh cs6715@192.168.8.208' # on a local vm
alias kenny_server='ssh nate@192.168.8.182' # on kels computer

# Source bash aliases if they exist
if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

# ============================================================================
# FUNCTIONS (Fish-like utilities)
# ============================================================================
# This section includes fish-like functions for better command-line experience:
# - Directory navigation helpers (up, .., ..., etc.)
# - Smart command suggestions (command_not_found_handle)
# - Git shortcuts and utilities
# - File management helpers

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

# Search command history with fzf
h() {
  local cmd
  cmd=$(history | awk '{$1=""; print substr($0,2)}' | fzf --tac --no-sort --exact --query="$*")
  if [ -n "$cmd" ]; then
    echo "$cmd"
    eval "$cmd"
  fi
}

# View CSV files interactively with visidata
csv() {
  if [ -f "$1" ]; then
    visidata "$1"
  else
    echo "File not found: $1"
    return 1
  fi
}

# View images in terminal with chafa
img() {
  if [ -f "$1" ]; then
    chafa "$1"
  else
    echo "File not found: $1"
    return 1
  fi
}

# View images with timg (supports animations)
imga() {
  if [ -f "$1" ]; then
    timg "$@"
  else
    echo "File not found: $1"
    return 1
  fi
}

# View PDFs in terminal (convert to images with timg)
pdf() {
  if [ -f "$1" ]; then
    timg "$1"
  else
    echo "File not found: $1"
    return 1
  fi
}

# ============================================================================
# DIRECTORY NAVIGATION
# ============================================================================
# Use: z <partial>  - smart jump to directory (zoxide)
#      zi           - interactive directory picker (defined below)
#      cd           - standard change directory

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'

# ============================================================================
# TOOL INITIALIZATION
# ============================================================================

# Lazy load pyenv - only initialize when actually used
if command -v pyenv &> /dev/null; then
  export PYENV_ROOT="$HOME/.pyenv"
  __add_to_path_if_exists "$PYENV_ROOT/bin"

  pyenv() {
    if [ -z "$PYENV_LOADED" ]; then
      export PYENV_LOADED=1
      eval "$(command pyenv init -)"
    fi
    command pyenv "$@"
  }
fi

# Lazy load rbenv - only initialize when actually used
if command -v rbenv &> /dev/null; then
  rbenv() {
    if [ -z "$RBENV_LOADED" ]; then
      export RBENV_LOADED=1
      eval "$(command rbenv init - bash)"
    fi
    command rbenv "$@"
  }
fi

# fnm (Fast Node Manager) - keep auto-loading for --use-on-cd feature
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

# ============================================================================
# ZOXIDE INTERACTIVE PICKER
# ============================================================================
# Note: zoxide init is handled by omarchy (see ~/.local/share/omarchy/default/bash/init)
# This just adds the interactive picker function

if command -v zoxide &> /dev/null; then
  zi() {
    local dir=$(zoxide query -i "$@")
    [ -n "$dir" ] && cd "$dir"
  }
fi

# Homebrew
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Cargo (Rust)
if [ -f "$HOME/.cargo/env" ]; then
  source "$HOME/.cargo/env"
fi

# Lazy load asdf - only when actually used
if [ -f "$HOME/.asdf/asdf.sh" ]; then
  asdf() {
    if [ -z "$ASDF_LOADED" ]; then
      export ASDF_LOADED=1
      source "$HOME/.asdf/asdf.sh"
      [ -f "$HOME/.asdf/completions/asdf.bash" ] && source "$HOME/.asdf/completions/asdf.bash"
    fi
    command asdf "$@"
  }
fi

# fzf (fuzzy finder) - Fish-like configuration
if command -v fzf &> /dev/null; then
  eval "$(fzf --bash)" 2>/dev/null || true

  # Fish-like fzf theme with better colors
  export FZF_DEFAULT_OPTS="
    --height 40%
    --layout=reverse
    --border
    --info=inline
    --prompt='❯ '
    --pointer='▶'
    --marker='✓'
    --color=fg:#c0caf5,bg:#1a1b26,hl:#7aa2f7
    --color=fg+:#c0caf5,bg+:#292e42,hl+:#7dcfff
    --color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff
    --color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a
  "

  # Use fd for faster file searching
  if command -v fd &> /dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  fi

  # Fish-like Ctrl+R for history search with preview
  if [[ ! -o vi ]]; then
    bind '"\C-r": "\C-x1\e^\C-x2\e[0n"'
    bind -x '"\C-x1": __fzf_history';
    bind '"\C-x2": redraw-current-line';

    __fzf_history() {
      local selected
      selected=$(fc -rl 1 | awk '{$1="";print substr($0,2)}' | fzf --tac --no-sort --exact --query="$READLINE_LINE")
      READLINE_LINE="$selected"
      READLINE_POINT=${#READLINE_LINE}
    }
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
