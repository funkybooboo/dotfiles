#!/usr/bin/env bash

line_exists() {
  local text="$1"
  local file="$2"

  # Return false if file doesn't exist
  [ ! -f "$file" ] && return 1

  # Check exact match
  grep -Fxq "$text" "$file" && return 0

  # Check with whitespace normalization
  local normalized_text=$(echo "$text" | sed 's/[[:space:]]\+/ /g' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  # Escape special regex characters more comprehensively
  local escaped_text=$(printf '%s\n' "$normalized_text" | sed 's/[][(){}*+?.|^$\\]/\\&/g')
  grep -x ".*${escaped_text}.*" "$file" >/dev/null 2>&1 && return 0

  return 1
}

append_to_config() {
  local text="$1"
  # Check for zsh and add .zshrc if found
  config_files=()
  if command -v zsh > /dev/null; then
    config_files+=("$HOME/.bashrc" "$HOME/.zshrc")
  else
    config_files+=("$HOME/.bashrc")
  fi

  # Loop through each file, append the text only if it exists
  for config_file in "${config_files[@]}"; do
    if [ -f "$config_file" ]; then
      if line_exists "$text" "$config_file"; then
        echo "Line '$text' (or similar) already exists in $config_file. Skipping..."
        continue
      fi

      printf "\n# Added by script at %s\n" "$(date)" >> "$config_file"
      echo "# BEGIN AUTO-ADDED LINE" >> "$config_file"
      echo "$text" | sed 's/^/# /' >> "$config_file"
      echo "# END AUTO-ADDED LINE" >> "$config_file"
      echo "Added $text to $config_file"
    else
      echo "Warning: No configuration file $config_file found. Skipping..."
    fi
  done
}

# Check if any arguments were passed, and use them as text to append
if [ $# -gt 0 ]; then
  # Process all arguments
  for arg in "$@"; do
    append_to_config "$arg"
  done
else
  echo "Usage: $0 <text to append>"
fi
