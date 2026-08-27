# fish_user_key_bindings -- custom key bindings (called by fish after the
# active fish_key_bindings mode, here fish_vi_key_bindings, is applied).
#
# Insert-mode binds prefixed with -M insert; default (normal) mode binds with
# -M default. \cP/\cN do history-search (prefix match) which beats plain
# up/down for recall. \cb accepts the whole autosuggestion.
function fish_user_key_bindings --description 'custom key bindings'
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
end
