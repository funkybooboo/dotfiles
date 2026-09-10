# One hdl layout per subdirectory of the current directory, each in its own tab.
# Usage: hdlm <c|cx|codex|other_ai> [<second_ai>]
function hdlm --argument-names ai ai2
    if test -z "$ai"
        echo "Usage: hdlm <c|cx|codex|other_ai> [<second_ai>]" >&2
        return 1
    end
    if not set -q HERDR_PANE_ID
        echo "You must start herdr to use hdlm." >&2
        return 1
    end

    set -l base_dir $PWD
    herdr workspace rename $HERDR_WORKSPACE_ID (basename $base_dir) >/dev/null

    # `path filter -d` keeps only directories and, unlike a bare glob, expands to
    # an empty list instead of aborting the loop when nothing matches.
    set -l first 1
    for dir in (path filter -d $base_dir/*)
        # The receiving pane runs fish, so escape for fish rather than with
        # bash's printf %q.
        set -l cmd "hdl "(string escape -- $ai)
        if test -n "$ai2"
            set cmd "$cmd "(string escape -- $ai2)
        end

        if test $first -eq 1
            # Reuse the current tab for the first project.
            herdr pane run $HERDR_PANE_ID "cd "(string escape -- $dir)" && $cmd" >/dev/null
            set first 0
        else
            set -l pane_id (herdr tab create --workspace $HERDR_WORKSPACE_ID --cwd $dir --no-focus |
                jq -r '.result.root_pane.pane_id')
            herdr pane run $pane_id $cmd >/dev/null
        end
    end
end
