set -e PYENV_ROOT
set -gx PYENV_ROOT $HOME/.pyenv

# Prevent multiple sourcing issues with a guard (optional but recommended)
if set -q __config_fish_sourced
    return
end
set -g __config_fish_sourced 1

# Add paths to PATH only if they exist (fish_add_path is idempotent)
function __add_to_path_if_exists
    test -d $argv[1]; and fish_add_path --path --move $argv[1]
end

__add_to_path_if_exists $HOME/.local/bin
# Add all subdirectories in ~/.local/bin to PATH
if test -d $HOME/.local/bin
    for dir in $HOME/.local/bin/*/
        test -d $dir; and fish_add_path --path --move $dir
    end
end

__add_to_path_if_exists $HOME/.cargo/bin
__add_to_path_if_exists $HOME/go/bin
__add_to_path_if_exists $HOME/.nix-profile/bin
__add_to_path_if_exists /nix/var/nix/profiles/default/bin
__add_to_path_if_exists $HOME/.pyenv/bin
__add_to_path_if_exists $HOME/.asdf/shims
__add_to_path_if_exists $HOME/.bun/bin

# Initialize pyenv only if installed
if type -q pyenv
    status is-login; and pyenv init --path | source
    status is-interactive; and pyenv init - | source
end

# Initialize fnm (Fast Node Manager) only once
if type -q fnm; and status is-interactive
    fnm env | source
end

# Set BUN_INSTALL if bun directory exists
if test -d $HOME/.bun
    set -gx BUN_INSTALL $HOME/.bun
end

# Interactive aliases - only set once in interactive sessions
if status is-interactive
    # Only set alias if command exists
    type -q eza; and alias ls='eza --icons'
    type -q fd; and alias find='fd'
    type -q fdfind; and alias fd='fdfind'
    type -q mtr; and alias ping='mtr --report --report-cycles 1'
    type -q procs; and alias ps='procs'
    type -q bat; and alias cat='bat'
    type -q batcat; and alias bat='batcat'
    type -q glances; and alias htop='glances'
    type -q duf; and alias df='duf'
    type -q multipass; and alias mp='multipass'

    # Server aliases
    alias raspberrypi_server='ssh nate@raspberrypi.local'
    alias dimension_server='ssh nate@192.168.0.134'
    alias tnas_server='ssh funkybooboo@192.168.8.238'
    alias middlechild_server='ssh root@139.59.173.228'
end

# Empty fish greeting
function fish_greeting
end

# Dotfiles git function
function dotfiles
    set -l dotfiles_dir $HOME/dotfiles/.git
    if test -d $dotfiles_dir
        /usr/bin/env git --git-dir=$dotfiles_dir --work-tree=$HOME/dotfiles $argv
    else
        echo "dotfiles directory not found: $dotfiles_dir" >&2
        return 1
    end
end

# Yazi function with cwd change
if type -q yazi
    function y
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        if test -f "$tmp"
            set cwd (command cat -- "$tmp")
            if test -n "$cwd" -a "$cwd" != "$PWD"
                builtin cd -- "$cwd"
            end
            rm -f -- "$tmp"
        end
    end
end

# SSH agent setup - only in interactive sessions
if status is-interactive
    if not set -q SSH_AUTH_SOCK; or not test -S $SSH_AUTH_SOCK
        if not pgrep -u (whoami) ssh-agent >/dev/null
            eval (ssh-agent -c) >/dev/null
        end
    end

    # Add SSH key if not already added
    if test -S $SSH_AUTH_SOCK; and test -f ~/.ssh/id_ed25519
        ssh-add -l >/dev/null 2>&1; or ssh-add ~/.ssh/id_ed25519 2>/dev/null
    end
end

# Initialize jump if available
if type -q jump
    jump shell fish | source
    alias j='jump'
end

# Initialize zoxide if available - this handles all z/zi commands
if type -q zoxide
    zoxide init fish | source
end

# Initialize Homebrew if available
if test -x /home/linuxbrew/.linuxbrew/bin/brew
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
end

# Ensure PYENV_ROOT is set
if not set -q PYENV_ROOT
    set -Ux PYENV_ROOT $HOME/.pyenv
end

# Ensure pyenv is in PATH only once
if not contains $PYENV_ROOT/bin $fish_user_paths
    set -U fish_user_paths $PYENV_ROOT/bin $fish_user_paths
end

# Initialize pyenv if available and not already initialized
if type -q pyenv
    if not set -q PYENV_LOADED
        set -g PYENV_LOADED 1
        pyenv init - fish | source
    end
end
