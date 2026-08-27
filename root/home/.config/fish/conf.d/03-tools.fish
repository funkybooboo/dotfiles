# 03-tools.fish -- interactive tool integration
#
# Each block is guarded so a missing tool is a no-op rather than an error.
# Sourced last so PATH/env from 00-env/01-path are already in place.

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

    # fzf --fish emits key bindings + completions; cache it so we don't fork
    # fzf on every shell start. Regenerate by deleting ~/.cache/fzf_fish_init.fish.
    set -l fzf_cache ~/.cache/fzf_fish_init.fish
    if not test -f $fzf_cache
        mkdir -p ~/.cache
        fzf --fish >$fzf_cache
    end
    source $fzf_cache
end

# direnv
if command -v direnv &>/dev/null
    direnv hook fish | source
end

# atuin -- shell history; --disable-up-arrow keeps up-arrow as line recall
if type -q atuin
    atuin init fish --disable-up-arrow | source
end

# zoxide -- smarter cd
if type -q zoxide
    zoxide init fish | source
end

# mise -- runtime version manager (node, python, go, ...)
if type -q mise
    mise activate fish | source
end

# starship prompt
if type -q starship
    starship init fish | source
end

# opam (OCaml toolchain)
test -r '/home/nate/.opam/opam-init/init.fish' \
    && source '/home/nate/.opam/opam-init/init.fish' >/dev/null 2>/dev/null; or true

# GPG: set GPG_TTY on first prompt, then self-destruct. Lazy so non-interactive
# shells (which never fire fish_prompt) don't waste a (tty) call.
function __gpg_tty_lazy --on-event fish_prompt
    set -gx GPG_TTY (tty)
    functions --erase __gpg_tty_lazy
end
