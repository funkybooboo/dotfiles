# y -- yazi, changing the cwd to yazi's last dir on exit
#
# Standard yazi cwd-switch wrapper: yazi writes its exit cwd to a temp file,
# and we cd there if it differs from $PWD. The cached function in
# share/fish/functions/yazi.fish from the yazi package does the same thing;
# this copy keeps it under dotfiles control.
function y --description 'yazi (cd to last dir on exit)'
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    command yazi $argv --cwd-file="$tmp"
    if read -z cwd <"$tmp"; and [ "$cwd" != "$PWD" ]; and test -d "$cwd"
        builtin cd -- "$cwd"
    end
    command rm -f -- "$tmp"
end
