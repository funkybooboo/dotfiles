# Aliases and short command wrappers.
#
# Split out of config.fish so there is exactly one definition site for these.
# Previously work's config.fish defined most of them inline while a separate
# functions/aliases.fish defined a second, partly conflicting set -- and that
# second file was dead. fish autoloads functions/NAME.fish by matching the
# function name to the filename, so a grab-bag file is only ever read if a
# function literally called `aliases` is invoked. Nothing invoked it, so cls,
# mkcd, lg, ld, lj and lsq were silently undefined, and `ll` quietly fell through
# to fish's own builtin (plain `ls -lh`, not eza).
#
# Where the two files disagreed on l / la / lt, the config.fish definitions are
# the ones kept here, because those are the ones that had actually been running.
# Do not "restore" the aliases.fish variants -- they were never in effect, so
# adopting them now would be a silent behaviour change, not a fix.

# eza-backed listings.
#
# Guarded on eza because an alias pointing at a missing binary fails only at the
# moment you use it, which is a confusing way to discover a half-provisioned
# machine. ll is defined the same as l deliberately: both are long listings and
# both are in muscle memory, and the point is that ll now uses eza like the rest
# rather than falling through to fish's builtin ls.
if type -q eza
    alias ls='eza --group-directories-first --icons=auto'
    alias l='eza -lh --group-directories-first --icons=auto'
    alias ll='eza -lh --group-directories-first --icons=auto'
    alias la='l -a'
    alias lt='eza --tree --level=2 --long --icons --git'
    alias lta='lt -a'
end

# TUI tools. Each is installed by a migration in both repos, so the guards are
# insurance for a partial provision rather than an expected branch.
if type -q lazygit
    alias lg='lazygit'
end
if type -q lazydocker
    alias ld='lazydocker'
end
if type -q lazyjournal
    alias lj='lazyjournal'
end
if type -q lazysql
    alias lsq='lazysql'
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
alias cls='clear'

# mkcd is a function rather than an alias because it takes an argument and
# chains on success -- an alias cannot reference $argv.
function mkcd --description 'mkdir -p a directory and cd into it'
    mkdir -p $argv[1]; and cd $argv[1]
end

# tools
alias d='docker'
alias t='tmux attach || tmux new -s Work'
