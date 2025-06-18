# Set PATH for local bin directories
set -gx PATH $HOME/.local/bin $PATH

# Alias ls to use lsd for interactive sessions
if status is-interactive
    alias ls=lsd
    alias mp='multipass'
end

# Empty fish_greeting function placeholder (remove if unnecessary)
function fish_greeting
    # Add greeting code here if needed
end

# Add Cargo bin directory to PATH permanently
set -Ux PATH $HOME/.cargo/bin $PATH

# Function for interacting with dotfiles using git
function dotfiles
    /usr/bin/env git --git-dir=$HOME/dotfiles/.git --work-tree=$HOME/dotfiles $argv
end

# Function for yazi tool with cwd check
function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if test -f "$tmp"
        set cwd (command cat -- "$tmp")
        if test -n "$cwd" -a "$cwd" != "$PWD"
            builtin cd -- "$cwd"
        end
    end
    rm -f -- "$tmp"
end

# Start ssh-agent if it's not already running
if not pgrep -u (whoami) ssh-agent >/dev/null
    eval (ssh-agent -c)
end

# Add SSH key if not already added and agent socket is valid
if test -S $SSH_AUTH_SOCK
    ssh-add -l >/dev/null
    or ssh-add ~/.ssh/id_ed25519 ^/dev/null
end

# Initialize zoxide for directory jumping
zoxide init fish | source

# Jump to the previous directory or add jump alias
jump shell fish | source

# Alias jump and zoxide commands
alias z='zoxide'
alias j='jump'

# Initialize fnm (Fast Node Manager) environment
fnm env | source
