# y -- yazi wrapper that leaves the shell in the directory yazi exited from.
#
# yazi runs as a child process, so it cannot change this shell's cwd itself.
# Instead it writes its final directory to the file named by --cwd-file, and
# this wrapper cds there afterwards. Upstream's fish snippet, kept verbatim so
# it does not drift from the yazi docs.

function y --description 'yazi, leaving the shell in the directory it exited from'
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    command yazi $argv --cwd-file="$tmp"
    if read -z cwd < "$tmp"; and [ "$cwd" != "$PWD" ]; and test -d "$cwd"
        builtin cd -- "$cwd"
    end
    command rm -f -- "$tmp"
end
