# Keybindings Menu Customization

**Last Updated:** 2026-01-02

## Overview

The Omarchy keybindings menu (Super + K) has been customized to execute actions when you press Enter on an item, rather than just closing the menu.

## What Was Changed

### Modified Script
- **File:** `~/.local/share/omarchy/bin/omarchy-menu-keybindings`
- **Source:** `~/dotfiles/omarchy/bin/omarchy-menu-keybindings`

### Modifications

The script was modified to:

1. **Create a mapping file** - When generating the menu, the script now creates a temporary file that maps each display line to its corresponding Hyprland dispatcher and arguments.

2. **Capture selection** - Instead of just displaying the menu and exiting, the script now captures which item was selected.

3. **Execute the action** - When an item is selected:
   - For `exec` dispatchers: The command is executed directly using `eval`
   - For other dispatchers: The action is executed via `hyprctl dispatch`

### Key Changes

#### parse_bindings function
- Now accepts a mapping file parameter
- Stores the relationship between formatted display lines and their dispatcher/args
- Writes mapping data to a temp file: `display_line → dispatcher → arg`

#### Main execution flow
```bash
# Create temp file for mapping
mapping_file=$(mktemp)
trap 'rm -f "$mapping_file"' EXIT

# Capture selection from walker
selection=$({...} | walker --dmenu ...)

# Execute if selection was made
if [[ -n "$selection" ]]; then
  # Look up dispatcher and args
  # Execute using appropriate method
fi
```

## Usage

Press **Super + K** to open the keybindings help menu. You can now:

1. Browse available keybindings
2. Search for specific actions
3. **Press Enter on any item to execute that action immediately**

## Installation

The modified script is automatically installed by `setup.sh`:
- Source location: `~/dotfiles/omarchy/bin/omarchy-menu-keybindings`
- Installed to: `~/.local/share/omarchy/bin/omarchy-menu-keybindings`

The setup script symlinks all scripts from `dotfiles/omarchy/bin/` to `~/.local/share/omarchy/bin/`.

## Technical Details

### Dispatcher Types

The script handles two types of actions:

1. **exec dispatchers** - Shell commands that should be run directly
   ```bash
   if [[ "$dispatcher" == "exec" ]]; then
     eval "$arg" &
   fi
   ```

2. **Hyprland dispatchers** - Window management actions
   ```bash
   elif [[ -n "$dispatcher" ]]; then
     hyprctl dispatch "$dispatcher" "$arg"
   fi
   ```

### Temporary File Management

- A temporary mapping file is created using `mktemp`
- The file is automatically cleaned up on script exit using `trap`
- Format: Tab-separated values (display_line, dispatcher, arg)

## Benefits

- **Faster workflow** - Execute actions directly from the help menu
- **Learning tool** - Try keybindings without memorizing them first
- **Discoverability** - Browse and test actions in one place
