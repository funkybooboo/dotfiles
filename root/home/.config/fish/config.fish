set -g fish_greeting

set -g fish_key_bindings fish_vi_key_bindings

# ============================================================================
# ENVIRONMENT
# ============================================================================
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx PAGER less
set -gx MANPAGER less
set -gx SUDO_EDITOR nvim
set -gx BAT_THEME "Catppuccin Mocha"
set -gx MANROFFOPT "-c"
set -gx LESSHISTFILE -
set -gx PYTHONSTARTUP $HOME/.config/python/pythonrc

# Libvirt: Use system connection by default for virt-manager and virsh
set -gx LIBVIRT_DEFAULT_URI "qemu:///system"

# ============================================================================
# PATH
# ============================================================================
fish_add_path -p $HOME/.local/bin
fish_add_path -p $HOME/.luarocks/bin
fish_add_path -p /var/lib/flatpak/exports/share
fish_add_path -p $HOME/.local/share/flatpak/exports/share

# nix — source the profile.d script (sets PATH, NIX_SSL_CERT_FILE,
# XDG_DATA_DIRS, NIX_PROFILES for nix-installed packages)
if test -f /etc/profile.d/nix-daemon.fish
    source /etc/profile.d/nix-daemon.fish
end

# ============================================================================
# COLORS (Catppuccin Mocha)
# ============================================================================
set -g fish_color_command cba6f7
set -g fish_color_keyword f5c2e7
set -g fish_color_param cdd6f4
set -g fish_color_option 89b4fa
set -g fish_color_normal cdd6f4
set -g fish_color_comment 6c7086
set -g fish_color_error f38ba8
set -g fish_color_redirection fab387
set -g fish_color_end f5e0dc
set -g fish_color_operator 89dceb
set -g fish_color_autosuggestion 7f849c
set -g fish_color_search_match --background=45475a
set -g fish_color_selection --background=45475a
set -g fish_pager_color_completion cdd6f4
set -g fish_pager_color_description a6adc8
set -g fish_pager_color_prefix cba6f7

# ============================================================================
# KEY BINDINGS
# ============================================================================
bind -M insert \cp history-search-backward
bind -M insert \cn history-search-forward
bind -M insert \cw backward-kill-word
bind -M insert \ck kill-line
bind -M insert \cu backward-kill-line
bind -M insert \cb accept-autosuggestion
bind -M default yy fish_clipboard_copy
bind -M default p fish_clipboard_paste
bind -M insert \e\[1\;5C forward-word
bind -M insert \e\[1\;5D backward-word

# ============================================================================
# ALIASES
# =============================================================================

# eza
if type -q eza
    alias ls='eza --group-directories-first --icons=auto'
    alias l='eza -lh --group-directories-first --icons=auto'
    alias la='l -a'
    alias lt='eza --tree --level=2 --long --icons --git'
    alias lta='lt -a'
end

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

# ============================================================================
# FUNCTIONS
# ============================================================================

function n
    if test (count $argv) -eq 0
        nvim .
    else
        nvim $argv
    end
end

function open
    xdg-open $argv >/dev/null 2>&1 &
    disown
end

function compress
    tar -czf (string replace -r '/$' '' -- $argv[1]).tar.gz $argv[1]
end

function decompress
    tar -xzf $argv[1]
end

# ============================================================================
# TOOL INITIALIZATION
# =============================================================================

# SSH agent
set -gx SSH_AUTH_SOCK $XDG_RUNTIME_DIR/ssh-agent.socket

# fzf
if command -v fzf &>/dev/null
    set -gx FZF_DEFAULT_OPTS "\
        --height 40% \
        --layout=reverse \
        --border \
        --prompt='❯ ' \
        --pointer='▶' \
        --color=bg:#1e1e2e,bg+:#313244,fg:#cdd6f4,fg+:#cdd6f4 \
        --color=hl:#f38ba8,hl+:#f38ba8,header:#f38ba8 \
        --color=info:#cba6f7,prompt:#cba6f7,pointer:#f5e0dc \
        --color=marker:#a6e3a1,spinner:#f5e0dc,border:#45475a"

    if command -v fd &>/dev/null
        set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
    end

    set -l fzf_cache ~/.cache/fzf_fish_init.fish
    if not test -f $fzf_cache
        mkdir -p ~/.cache
        fzf --fish > $fzf_cache
    end
    source $fzf_cache
end

# direnv
if command -v direnv &>/dev/null
    direnv hook fish | source
end

# GPG - lazy load TTY on first prompt
function __gpg_tty_lazy --on-event fish_prompt
    set -gx GPG_TTY (tty)
    functions --erase __gpg_tty_lazy
end

# atuin
if type -q atuin
    atuin init fish --disable-up-arrow | source
end

# zoxide
if type -q zoxide
    zoxide init fish | source
end

# mise
if type -q mise
    mise activate fish | source
end

# starship
if type -q starship
    starship init fish | source
end

# opam
test -r '/home/nate/.opam/opam-init/init.fish' && source '/home/nate/.opam/opam-init/init.fish' > /dev/null 2> /dev/null; or true