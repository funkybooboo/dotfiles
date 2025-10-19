#!/usr/bin/env bash
set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/log.sh"

copy_to_clipboard() {
    local text="$1"
    local copied=false

    # Print the text to the terminal
    log "----------------------------------------"
    echo "$text"
    log "----------------------------------------"

    # Try common clipboard tools
    if command -v xclip >/dev/null 2>&1; then
        echo -n "$text" | xclip -selection clipboard
        copied=true
    elif command -v pbcopy >/dev/null 2>&1; then
        echo -n "$text" | pbcopy
        copied=true
    elif command -v wl-copy >/dev/null 2>&1; then
        echo -n "$text" | wl-copy
        copied=true
    fi

    # Print/log result
    if [[ "$copied" = true ]]; then
        log "Text copied to your clipboard."
    else
        log "No clipboard manager found; please copy the text manually."
    fi
}
