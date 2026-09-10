# Build a herdr dev layout in the current tab: editor, AI, and a terminal strip.
# Usage: hdl <c|cx|codex|other_ai> [<second_ai>]
function hdl --argument-names ai ai2
    if test -z "$ai"
        echo "Usage: hdl <c|cx|codex|other_ai> [<second_ai>]" >&2
        return 1
    end
    if not set -q HERDR_PANE_ID
        echo "You must start herdr to use hdl." >&2
        return 1
    end

    set -l current_dir $PWD
    # HERDR_PANE_ID names the pane this ran in and stays correct even though the
    # splits below move focus around.
    set -l editor_pane $HERDR_PANE_ID

    herdr tab rename $HERDR_TAB_ID (basename $current_dir) >/dev/null

    # Terminal strip across the bottom 15%.
    _herdr_split $editor_pane down 0.85 $current_dir >/dev/null

    # AI down the right 30%.
    set -l ai_pane (_herdr_split $editor_pane right 0.7 $current_dir)

    if test -n "$ai2"
        set -l ai2_pane (_herdr_split $ai_pane down 0.5 $current_dir)
        herdr pane run $ai2_pane $ai2 >/dev/null
    end

    herdr pane run $ai_pane $ai >/dev/null
    herdr pane run $editor_pane "$EDITOR ." >/dev/null
end
