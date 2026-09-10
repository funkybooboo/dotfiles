# Tile the current tab into <pane_count> panes and start <command> in every one.
# Usage: hsl <pane_count> <command>
function hsl --argument-names count cmd
    if test -z "$count" -o -z "$cmd"
        echo "Usage: hsl <pane_count> <command>" >&2
        return 1
    end
    if not set -q HERDR_PANE_ID
        echo "You must start herdr to use hsl." >&2
        return 1
    end

    set -l current_dir $PWD
    herdr tab rename $HERDR_TAB_ID (basename $current_dir) >/dev/null

    # ceil(sqrt(count)) columns, with the rows spread across them.
    set -l cols 1
    while test (math "$cols * $cols") -lt $count
        set cols (math $cols + 1)
    end

    # Peel each new column off the rightmost one at 1/(n-k+1), which leaves the
    # list in left-to-right order.
    set -l columns $HERDR_PANE_ID
    for k in (seq 1 (math $cols - 1))
        set -a columns (_herdr_split $columns[-1] right \
            (_herdr_ratio 1 (math "$cols - $k + 1")) $current_dir)
    end

    # Split each column into its share of rows, evenly, top to bottom. floor() is
    # required: bare math rounds, which would over-count rows on a ragged grid.
    set -l remainder (math "$count % $cols")
    set -l panes
    for index in (seq $cols)
        set -l col $columns[$index]
        set -l rows (math "floor($count / $cols)")
        # The bash original tested a 0-based index against the remainder; seq is
        # 1-based, so the columns taking an extra row are 1..remainder here.
        if test $index -le $remainder
            set rows (math $rows + 1)
        end
        set -a panes $col
        set -l last $col
        for j in (seq 1 (math $rows - 1))
            set last (_herdr_split $last down \
                (_herdr_ratio 1 (math "$rows - $j + 1")) $current_dir)
            set -a panes $last
        end
    end

    for pane in $panes
        herdr pane run $pane $cmd >/dev/null
    end
end
