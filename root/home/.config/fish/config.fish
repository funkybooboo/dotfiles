# Minimal Fish Configuration
# Only run in interactive mode
if not status is-interactive
    return
end

# ============================================================================
# OMARCHY INTEGRATION
# ============================================================================
if test -f ~/.local/share/omarchy/default/fish/rc
    source ~/.local/share/omarchy/default/fish/rc
end

# ============================================================================
# ENVIRONMENT
# ============================================================================
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx PAGER less
set -gx LESS -R

# ============================================================================
# PATH
# ============================================================================
fish_add_path -p $HOME/.local/bin
fish_add_path -p $HOME/.cargo/bin
fish_add_path -p /var/lib/flatpak/exports/share
fish_add_path -p $HOME/.local/share/flatpak/exports/share

# ============================================================================
# FUNCTIONS
# ============================================================================
function mkcd
    mkdir -p $argv[1]
    and cd $argv[1]
end

# ============================================================================
# TOOL INITIALIZATION
# ============================================================================
# SSH agent
set -gx SSH_AUTH_SOCK $XDG_RUNTIME_DIR/ssh-agent.socket

# fzf
if command -v fzf &>/dev/null
    set -gx FZF_DEFAULT_OPTS "\
        --height 40% \
        --layout=reverse \
        --border \
        --prompt='❯ ' \
        --pointer='▶'"

    if command -v fd &>/dev/null
        set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
    end

    fzf --fish | source
end

# direnv
if command -v direnv &>/dev/null
    direnv hook fish | source
end

# GPG
set -gx GPG_TTY (tty)

# ============================================================================
# SETTINGS
# ============================================================================
set -g fish_greeting
fish_vi_key_bindings
