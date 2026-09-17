# Shadows any `open` binary on PATH deliberately: xdg-open is the correct
# opener on Linux, and disown keeps the launched app from tying up this shell.
function open --description 'xdg-open, detached from the shell'
    xdg-open $argv >/dev/null 2>&1 &
    disown
end
