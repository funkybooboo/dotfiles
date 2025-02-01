if status is-interactive
    alias ls=lsd
end

function fish_greeting

end

set -gx PATH /home/nate/.config/nixos/ $PATH
set -gx PATH $HOME/.cargo/bin $PATH

function dotfiles
    /usr/bin/env git --git-dir=$HOME/dotfiles/ --work-tree=$HOME $argv
end

fnm env | source
