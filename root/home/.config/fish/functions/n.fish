function n --description 'nvim on the cwd, or on the given paths'
    if test (count $argv) -eq 0
        nvim .
    else
        nvim $argv
    end
end
