function cls
    clear
end

function ..
    cd ..
end

function ...
    cd ../..
end

function ....
    cd ../../..
end

function mkcd
    mkdir -p $argv[1] && cd $argv[1]
end

function l
    eza --icons --git $argv
end

function ll
    eza --icons --git -l $argv
end

function la
    eza --icons --git -la $argv
end

function lt
    eza --icons --git -la --tree --level=2 $argv
end

function lg
    lazygit $argv
end

function ld
    lazydocker $argv
end

function lj
    lazyjournal $argv
end

function lsq
    lazysql $argv
end