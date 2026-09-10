# Split a herdr pane and echo the id of the new pane.
# Usage: _herdr_split <pane_id> <right|down> <ratio> <cwd>
#
# --no-focus leaves the caller's pane focused, so a layout builder can keep
# splitting from a pane it already knows instead of chasing focus.
function _herdr_split --argument-names pane direction ratio cwd
    herdr pane split $pane --direction $direction --ratio $ratio --cwd $cwd --no-focus |
        jq -r '.result.pane.pane_id'
end
