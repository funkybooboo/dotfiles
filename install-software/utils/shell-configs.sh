#!/usr/bin/env bash

set -e
set -o pipefail

# ============================
# Utils to append to shell configs
# ============================

# Add a directory to PATH in both bash (~/.profile) and fish (~/.config/fish/config.fish) idempotently
add_path_bash_and_fish() {
    local newpath="$1"
    local bash_line="export PATH=\"$newpath:\$PATH\""
    local bash_profile="$HOME/.profile"

    # Bash
    if ! grep -Fxq "$bash_line" "$bash_profile" 2>/dev/null; then
        echo "$bash_line" >>"$bash_profile"
    fi

    # Fish
    if command -v fish &>/dev/null; then
        local fish_cfg="$HOME/.config/fish/config.fish"
        mkdir -p "$(dirname "$fish_cfg")"
        # Use fish_add_path only if not already present
        if ! grep -Fq "$newpath" "$fish_cfg" 2>/dev/null; then
            echo "fish_add_path --prepend \"$newpath\"" >>"$fish_cfg"
        fi
    fi
}

# Add an eval command (e.g., Homebrew shellenv) to bash and fish configs idempotently
add_eval_bash_and_fish() {
    local eval_cmd="$1"
    local bash_profile="$HOME/.profile"

    # Bash
    if ! grep -Fxq "$eval_cmd" "$bash_profile" 2>/dev/null; then
        echo "$eval_cmd" >>"$bash_profile"
    fi

    # Fish
    if command -v fish &>/dev/null; then
        local fish_cfg="$HOME/.config/fish/config.fish"
        mkdir -p "$(dirname "$fish_cfg")"
        local fish_line="eval ( $eval_cmd | psub )"
        if ! grep -Fq "$fish_line" "$fish_cfg" 2>/dev/null; then
            echo "$fish_line" >>"$fish_cfg"
        fi
    fi
}
