# Echo a split ratio as a float, for _herdr_split's --ratio.
# Usage: _herdr_ratio <numerator> <denominator>
#
# omarchy shelled out to awk for this; fish's math does it directly, and -s4
# fixes the scale so the result never comes back in exponent form.
function _herdr_ratio --argument-names numerator denominator
    math -s4 "$numerator / $denominator"
end
