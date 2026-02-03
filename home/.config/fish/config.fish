# ~/.config/fish/config.fish
#
# MINIMAL YET POWERFUL FISH CONFIGURATION
# ========================================
# Philosophy: Use tools as developers intended
#
# Features:
# ✓ Starship prompt (beautiful, git-aware)
# ✓ Zoxide (smart directory jumping: z, zi)
# ✓ Enhanced history (built-in to fish)
# ✓ Fuzzy finder (fzf: Ctrl+T, Ctrl+R, Alt+C)
# ✓ Autosuggestions (built-in to fish)
# ✓ Syntax highlighting (built-in to fish)
# ✓ Smart completions (built-in to fish)
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

# Only run in interactive mode
if not status is-interactive
    exit
end

# ============================================================================
# OMARCHY DEFAULTS
# ============================================================================
# Load Omarchy default fish configuration (if available)
if test -f ~/.local/share/omarchy/default/fish/rc
    source ~/.local/share/omarchy/default/fish/rc
end

# ============================================================================
# ENVIRONMENT VARIABLES
# ============================================================================
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx PAGER less
set -gx LESS -R
set -gx PYENV_ROOT $HOME/.pyenv
set -gx BUN_INSTALL $HOME/.bun
set -gx LIBVIRT_DEFAULT_URI qemu:///system

# ============================================================================
# PATH CONFIGURATION
# ============================================================================
# Fish has a built-in fish_add_path function that handles duplicates

# Add local bin directory
fish_add_path -p $HOME/.local/bin

# Add all subdirectories in ~/.local/bin to PATH
if test -d $HOME/.local/bin
    for dir in $HOME/.local/bin/*/
        if test -d $dir
            fish_add_path -p $dir
        end
    end
end

# Flatpak exports
fish_add_path -p /var/lib/flatpak/exports/share
fish_add_path -p $HOME/.local/share/flatpak/exports/share

# Development tools
fish_add_path -p $HOME/.cargo/bin
fish_add_path -p $HOME/go/bin
fish_add_path -p $HOME/.nix-profile/bin
fish_add_path -p /nix/var/nix/profiles/default/bin
fish_add_path -p $PYENV_ROOT/bin
fish_add_path -p $HOME/.asdf/shims
fish_add_path -p $BUN_INSTALL/bin

# Ruby and Bundler
fish_add_path -p $HOME/.rbenv/bin
fish_add_path -p $HOME/.rbenv/shims

# RubyGems user install (version-agnostic)
if test -d $HOME/.local/share/gem/ruby
    for ruby_dir in $HOME/.local/share/gem/ruby/*/bin
        if test -d $ruby_dir
            fish_add_path -p $ruby_dir
        end
    end
end

# Additional language package managers
fish_add_path -p $HOME/.deno/bin
fish_add_path -p $HOME/.local/share/pnpm
fish_add_path -p $HOME/.config/composer/vendor/bin
fish_add_path -p /var/lib/snapd/snap/bin
fish_add_path -p $HOME/.opencode/bin

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
if command -v eza &>/dev/null
    alias ls 'eza'
    alias la 'eza -a'
    alias ll 'eza -la'
end

# VSCodium - only if code doesn't exist
if command -v codium &>/dev/null
    if not command -v code &>/dev/null
        alias code 'codium'
    end
end

# go-task - only if task doesn't exist
if command -v go-task &>/dev/null
    if not command -v task &>/dev/null
        alias task 'go-task'
    end
end

# Server aliases
alias raspberrypi_server 'ssh nate@raspberrypi.lan'
alias dimension_server 'ssh nate@192.168.8.210'
alias tnas_server 'ssh funkybooboo@nas.lan'
alias middlechild_server 'ssh root@middlechild.cloud'
alias cs6715_server 'ssh cs6715@192.168.8.208'
alias kenny_server 'ssh nate@192.168.8.182'

# Directory navigation shortcuts
alias .. 'cd ..'
alias ... 'cd ../..'
alias .... 'cd ../../..'
# Note: 'cd -' already works in fish to go to previous directory

# ============================================================================
# FUNCTIONS
# ============================================================================

# Dotfiles git function
function dotfiles
    set dotfiles_dir $HOME/dotfiles/.git
    if test -d $dotfiles_dir
        /usr/bin/env git --git-dir=$dotfiles_dir --work-tree=$HOME/dotfiles $argv
    else
        echo "dotfiles directory not found: $dotfiles_dir" >&2
        return 1
    end
end

# Yazi function with cwd change
if command -v yazi &>/dev/null
    function y
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file=$tmp
        if test -f $tmp
            set cwd (cat -- $tmp)
            if test -n "$cwd" -a "$cwd" != "$PWD"
                builtin cd -- $cwd
            end
            rm -f -- $tmp
        end
    end
end

# Quick directory navigation
function mkcd
    mkdir -p $argv[1]
    and cd $argv[1]
end

# Extract archives
function extract
    if test -f $argv[1]
        switch $argv[1]
            case '*.tar.bz2'
                tar xjf $argv[1]
            case '*.tar.gz'
                tar xzf $argv[1]
            case '*.bz2'
                bunzip2 $argv[1]
            case '*.rar'
                unrar x $argv[1]
            case '*.gz'
                gunzip $argv[1]
            case '*.tar'
                tar xf $argv[1]
            case '*.tbz2'
                tar xjf $argv[1]
            case '*.tgz'
                tar xzf $argv[1]
            case '*.zip'
                unzip $argv[1]
            case '*.Z'
                uncompress $argv[1]
            case '*.7z'
                7z x $argv[1]
            case '*'
                echo "'$argv[1]' cannot be extracted via extract()"
        end
    else
        echo "'$argv[1]' is not a valid file"
    end
end

# Show command history stats
function histstat
    history | awk '{CMD[$1]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | grep -v "./" | column -c3 -s " " -t | sort -nr | nl | head -n20
end

# Search command history with fzf
function h
    set cmd (history | fzf --tac --no-sort --exact --query="$argv")
    if test -n "$cmd"
        echo $cmd
        eval $cmd
    end
end

# View CSV files interactively with visidata
function csv
    if test -f $argv[1]
        visidata $argv[1]
    else
        echo "File not found: $argv[1]"
        return 1
    end
end

# View images in terminal with chafa
function img
    if test -f $argv[1]
        chafa $argv[1]
    else
        echo "File not found: $argv[1]"
        return 1
    end
end

# View images with timg (supports animations)
function imga
    if test -f $argv[1]
        timg $argv
    else
        echo "File not found: $argv[1]"
        return 1
    end
end

# View PDFs in terminal (convert to images with timg)
function pdf
    if test -f $argv[1]
        timg $argv[1]
    else
        echo "File not found: $argv[1]"
        return 1
    end
end

# ============================================================================
# TOOL INITIALIZATION
# ============================================================================

# Lazy load pyenv - only initialize when actually used
if command -v pyenv &>/dev/null
    function pyenv
        if not set -q PYENV_LOADED
            set -gx PYENV_LOADED 1
            source (command pyenv init - | psub)
        end
        command pyenv $argv
    end
end

# Lazy load rbenv - only initialize when actually used
if command -v rbenv &>/dev/null
    function rbenv
        if not set -q RBENV_LOADED
            set -gx RBENV_LOADED 1
            source (command rbenv init - | psub)
        end
        command rbenv $argv
    end
end

# fnm (Fast Node Manager) - keep auto-loading for --use-on-cd feature
if command -v fnm &>/dev/null
    fnm env --use-on-cd | source
end

# -------------------------------
# SSH agent setup with KWallet integration
# -------------------------------
# Use persistent ssh-agent from systemd service
set -gx SSH_AUTH_SOCK $XDG_RUNTIME_DIR/ssh-agent.socket

# Configure SSH to use ksshaskpass for passphrase prompts (integrates with KWallet)
set -gx SSH_ASKPASS /usr/bin/ksshaskpass
set -gx SSH_ASKPASS_REQUIRE prefer

# Add ED25519 key if not already added
if test -f $HOME/.ssh/id_ed25519
    ssh-add -l >/dev/null 2>&1
    or ssh-add $HOME/.ssh/id_ed25519 </dev/null >/dev/null 2>&1
end

# Initialize jump if available
if command -v jump &>/dev/null
    jump shell fish | source
    alias j 'jump'
end

# ============================================================================
# ZOXIDE INTERACTIVE PICKER
# ============================================================================
# Note: zoxide init is handled by omarchy (see ~/.local/share/omarchy/default/fish/init)
# This just adds the interactive picker function

if command -v zoxide &>/dev/null
    function zi
        set dir (zoxide query -i $argv)
        test -n "$dir"
        and cd $dir
    end
end

# Homebrew
if test -x /home/linuxbrew/.linuxbrew/bin/brew
    eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
end

# Cargo (Rust)
if test -f $HOME/.cargo/env
    source $HOME/.cargo/env.fish
end

# Lazy load asdf - only when actually used
if test -f $HOME/.asdf/asdf.fish
    function asdf
        if not set -q ASDF_LOADED
            set -gx ASDF_LOADED 1
            source $HOME/.asdf/asdf.fish
        end
        command asdf $argv
    end
end

# fzf (fuzzy finder)
if command -v fzf &>/dev/null
    # Fish-like fzf theme with better colors
    set -gx FZF_DEFAULT_OPTS "\
        --height 40% \
        --layout=reverse \
        --border \
        --info=inline \
        --prompt='❯ ' \
        --pointer='▶' \
        --marker='✓' \
        --color=fg:#c0caf5,bg:#1a1b26,hl:#7aa2f7 \
        --color=fg+:#c0caf5,bg+:#292e42,hl+:#7dcfff \
        --color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff \
        --color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a"

    # Use fd for faster file searching
    if command -v fd &>/dev/null
        set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
        set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
        set -gx FZF_ALT_C_COMMAND 'fd --type d --hidden --follow --exclude .git'
    end

    # Initialize fzf key bindings and completions
    fzf --fish | source
end

# direnv (auto-load environment variables)
if command -v direnv &>/dev/null
    direnv hook fish | source
end

# GPG TTY
set -gx GPG_TTY (tty)

# ============================================================================
# FISH-SPECIFIC SETTINGS
# ============================================================================

# Disable greeting message
set -g fish_greeting

# Enable VI mode
fish_vi_key_bindings

# Set color scheme (optional - fish has great defaults)
# You can customize colors with: set fish_color_* values
