if status is-interactive
    alias ls=lsd
end

function fish_greeting

end

set -gx PATH /home/nate/.config/nixos/ $PATH

set -Ux PATH $HOME/.cargo/bin $PATH


function dotfiles
    /usr/bin/env git --git-dir=$HOME/dotfiles/ --work-tree=$HOME $argv
end

function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

jump shell fish | source

alias z='zoxide'
alias j='jump'

fnm env | source
