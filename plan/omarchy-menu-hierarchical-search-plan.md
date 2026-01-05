# Implementation Plan: Hierarchical Search for Omarchy Menu

## Problem Statement

**Current Limitation:**
The omarchy menu system requires users to navigate through multiple hierarchical levels to reach deep menu items. For example, to install a package, users must:
1. Open main menu
2. Select "Install"
3. Select "Package"

**User Requirement:**
Enable searching across the entire menu hierarchy from the main menu. When a user types "package" in the main menu, they should see "Install → Package" as an option and be able to jump directly to that action without navigating through intermediate menus.

## Solution Approach

**Hybrid Menu Architecture:**
Implement a hybrid approach that preserves existing hierarchical navigation while enabling global search:
- Main menu displays both top-level items AND all submenu items with breadcrumb labels
- Walker's built-in fuzzy search filters both sets naturally
- Users can browse hierarchically (current behavior) OR search and jump directly (new capability)
- No mode switching required - search "just works"

**Why This Approach:**
1. ✅ Preserves existing navigation patterns (backwards compatible)
2. ✅ Minimal code changes (additive, not destructive)
3. ✅ Leverages Walker's existing search capabilities
4. ✅ Clean user experience (no mode switching)
5. ✅ Maintainable (clear separation of concerns)

## Technical Implementation

### Architecture Overview

The solution adds four key components:

1. **`build_flat_menu_map()`** - Generates complete list of all menu items with breadcrumbs
2. **Modified `show_main_menu()`** - Combines top-level + flattened items
3. **Enhanced `go_to_menu()`** - Detects and routes breadcrumb selections
4. **`handle_breadcrumb_selection()`** - Maps action IDs to commands

### File Changes

**Primary file:** `/home/nate/.local/share/omarchy/bin/omarchy-menu`

**Total changes:**
- ~250-300 new lines (two new functions)
- ~7 modified lines (two existing functions)
- 0 deleted lines
- Final script size: ~740-786 lines (from 486 lines)

### Implementation Steps

#### Step 1: Add `build_flat_menu_map()` Function

**Location:** After line 37 (after the `aur_install_and_launch()` function)

**Purpose:** Generate a complete flat map of all actionable menu items with breadcrumbs.

**Format:**
```
icon  Parent → Child → Action|action_id
```

**Example entries:**
```bash
build_flat_menu_map() {
  cat <<-'EOF'
	  Learn → Keybindings|learn_keybindings
	  Learn → Omarchy|learn_omarchy
	  Trigger → Capture → Screenshot → Snap with Editing|screenshot_edit
	  Trigger → Capture → Screenshot → Straight to Clipboard|screenshot_clipboard
	  Trigger → Toggle → Screensaver|toggle_screensaver
	  Style → Theme|style_theme
	  Style → Background|style_background
	󰉉  Install → Package|install_package
	󰣇  Install → AUR|install_aur
	󰵮  Install → Development → Ruby on Rails|install_rails
	󰵮  Install → Development → JavaScript → Node.js|install_node
	  Install → Terminal → Alacritty|install_alacritty
	  System → Lock|system_lock
	  System → Shutdown|system_shutdown
	EOF
}
```

**Complete mapping:** ~150-200 entries covering all actionable items across all submenus.

**Key decisions:**
- Use ` → ` (space-arrow-space) as breadcrumb separator for clarity
- Use `|` to separate display text from action_id (hidden from user)
- Preserve original icon from deepest menu level
- Include ALL actionable items (leaf nodes) but exclude intermediate navigation menus

#### Step 2: Add `handle_breadcrumb_selection()` Function

**Location:** After `build_flat_menu_map()` function

**Purpose:** Parse breadcrumb selections and execute corresponding actions.

**Implementation:**
```bash
handle_breadcrumb_selection() {
  local selection="$1"
  local action_id="${selection##*|}"  # Extract everything after last |

  # Safety check
  if [[ -z "$action_id" || "$action_id" == "$selection" ]]; then
    # No action_id found, treat as regular menu item
    return 1
  fi

  case "$action_id" in
    # Learn menu
    learn_keybindings) omarchy-menu-keybindings ;;
    learn_omarchy) omarchy-launch-webapp "https://learn.omacom.io/2/the-omarchy-manual" ;;
    learn_hyprland) omarchy-launch-webapp "https://wiki.hypr.land/" ;;
    learn_arch) omarchy-launch-webapp "https://wiki.archlinux.org/title/Main_page" ;;
    learn_neovim) omarchy-launch-webapp "https://www.lazyvim.org/keymaps" ;;
    learn_bash) omarchy-launch-webapp "https://devhints.io/bash" ;;

    # Trigger → Capture menu
    screenshot_edit) omarchy-cmd-screenshot smart ;;
    screenshot_clipboard) omarchy-cmd-screenshot smart clipboard ;;
    screenrecord_desktop) omarchy-cmd-screenrecord --with-desktop-audio ;;
    screenrecord_desktop_mic) omarchy-cmd-screenrecord --with-desktop-audio --with-microphone-audio ;;
    screenrecord_desktop_mic_webcam) omarchy-cmd-screenrecord --with-desktop-audio --with-microphone-audio --with-webcam ;;
    capture_color) pkill hyprpicker || hyprpicker -a ;;

    # Trigger → Share menu
    share_clipboard) omarchy-cmd-share clipboard ;;
    share_file) terminal bash -c "omarchy-cmd-share file" ;;
    share_folder) terminal bash -c "omarchy-cmd-share folder" ;;

    # Trigger → Toggle menu
    toggle_screensaver) omarchy-toggle-screensaver ;;
    toggle_nightlight) omarchy-toggle-nightlight ;;
    toggle_idle) omarchy-toggle-idle ;;
    toggle_bar) omarchy-toggle-waybar ;;

    # Style menu
    style_theme) show_theme_menu ;;
    style_background) omarchy-theme-bg-next ;;
    style_hyprland) open_in_editor ~/.config/hypr/looknfeel.conf ;;
    style_screensaver) open_in_editor ~/.config/omarchy/branding/screensaver.txt ;;
    style_about) open_in_editor ~/.config/omarchy/branding/about.txt ;;

    # Install menu
    install_package) terminal omarchy-pkg-install ;;
    install_aur) terminal omarchy-pkg-aur-install ;;
    install_webapp) present_terminal omarchy-webapp-install ;;
    install_tui) present_terminal omarchy-tui-install ;;
    install_rails) present_terminal "omarchy-install-dev-env ruby" ;;
    install_node) present_terminal "omarchy-install-dev-env node" ;;
    install_alacritty) install_terminal "alacritty" ;;
    install_steam) present_terminal omarchy-install-steam ;;

    # System menu
    system_lock) omarchy-lock-screen ;;
    system_screensaver) omarchy-launch-screensaver force ;;
    system_restart) omarchy-cmd-reboot ;;
    system_shutdown) omarchy-cmd-shutdown ;;

    # Fallback for unknown actions
    *)
      notify-send "Omarchy Menu" "Unknown action: $action_id"
      show_main_menu
      ;;
  esac
}
```

**Total action mappings:** ~100-150 entries covering all leaf actions.

#### Step 3: Modify `show_main_menu()` Function

**Current implementation (line 456-458):**
```bash
show_main_menu() {
  go_to_menu "$(menu "Go" "󰀻  Apps\n󰧑  Learn\n󱓞  Trigger\n  Style\n  Setup\n󰉉  Install\n󰭌  Remove\n  Update\n  About\n  System")"
}
```

**New implementation:**
```bash
show_main_menu() {
  local top_level="󰀻  Apps\n󰧑  Learn\n󱓞  Trigger\n  Style\n  Setup\n󰉉  Install\n󰭌  Remove\n  Update\n  About\n  System"
  local flat_items="$(build_flat_menu_map)"
  local combined="$top_level\n$flat_items"

  go_to_menu "$(menu "Go" "$combined")"
}
```

**Changes:**
- Extract top-level items to variable
- Call `build_flat_menu_map()` to get all submenu items
- Combine both lists with newline separator
- Pass combined list to menu

**User experience:**
- First 10 items are top-level (familiar)
- Next 150-200 items are searchable submenu items
- When user types, Walker filters entire list
- Typing "package" shows "Install → Package"
- Typing "rails" shows "Install → Development → Ruby on Rails"

#### Step 4: Enhance `go_to_menu()` Function

**Current implementation (line 460-478):**
```bash
go_to_menu() {
  case "${1,,}" in
  *apps*) walker -p "Launch…" ;;
  *learn*) show_learn_menu ;;
  # ... rest of cases ...
  esac
}
```

**New implementation:**
```bash
go_to_menu() {
  local selection="$1"

  # Check if this is a breadcrumb selection (contains →)
  if [[ "$selection" == *"→"* ]]; then
    handle_breadcrumb_selection "$selection"
    return
  fi

  # Original case statement unchanged
  case "${selection,,}" in
  *apps*) walker -p "Launch…" ;;
  *learn*) show_learn_menu ;;
  *trigger*) show_trigger_menu ;;
  *share*) show_share_menu ;;
  *style*) show_style_menu ;;
  *theme*) show_theme_menu ;;
  *screenshot*) show_screenshot_menu ;;
  *screenrecord*) show_screenrecord_menu ;;
  *setup*) show_setup_menu ;;
  *power*) show_setup_power_menu ;;
  *install*) show_install_menu ;;
  *remove*) show_remove_menu ;;
  *update*) show_update_menu ;;
  *about*) omarchy-launch-about ;;
  *system*) show_system_menu ;;
  esac
}
```

**Changes:**
- Add breadcrumb detection before case statement
- If selection contains `→`, route to `handle_breadcrumb_selection()`
- Otherwise, use existing case statement (preserves current behavior)

**Backwards compatibility:** 100% - all existing menu navigation continues to work.

### Menu Item Format Specification

**Display format (visible to user):**
```
icon  Level1 → Level2 → Level3
```

**Internal format (piped to Walker):**
```
icon  Level1 → Level2 → Level3|action_id
```

**Separator meanings:**
- ` → ` (U+2192): Breadcrumb path separator
- `|`: Display/action delimiter (hidden from user by Walker)

**Examples:**
- `  Learn → Keybindings|learn_keybindings`
- `󰉉  Install → Package|install_package`
- `󰵮  Install → Development → Ruby on Rails|install_rails`
- `  System → Shutdown|system_shutdown`

**Icon strategy:**
Use the icon from the **deepest menu level** for each item:
- `  Install → Terminal → Alacritty|install_alacritty` (uses Terminal icon)
- `󰵮  Install → Development → Ruby on Rails|install_rails` (uses Development icon)

### Complete Menu Hierarchy Mapping

Based on analysis of omarchy-menu:486, here are all actionable items to include:

**Learn (6 items):**
- Learn → Keybindings
- Learn → Omarchy
- Learn → Hyprland
- Learn → Arch
- Learn → Neovim
- Learn → Bash

**Trigger → Capture (8 items):**
- Trigger → Capture → Screenshot → Snap with Editing
- Trigger → Capture → Screenshot → Straight to Clipboard
- Trigger → Capture → Screenrecord → With desktop audio
- Trigger → Capture → Screenrecord → With desktop + microphone audio
- Trigger → Capture → Screenrecord → With desktop + microphone + webcam
- Trigger → Capture → Color

**Trigger → Share (3 items):**
- Trigger → Share → Clipboard
- Trigger → Share → File
- Trigger → Share → Folder

**Trigger → Toggle (4 items):**
- Trigger → Toggle → Screensaver
- Trigger → Toggle → Nightlight
- Trigger → Toggle → Idle Lock
- Trigger → Toggle → Top Bar

**Style (6 items):**
- Style → Theme
- Style → Font
- Style → Background
- Style → Hyprland
- Style → Screensaver
- Style → About

**Setup (20+ items):**
- Setup → Audio
- Setup → Wifi
- Setup → Bluetooth
- Setup → Power Profile
- Setup → Monitors
- Setup → Keybindings
- Setup → Input
- Setup → Defaults
- Setup → DNS
- Setup → Security → Fingerprint
- Setup → Security → Fido2
- Setup → Config → Hyprland
- Setup → Config → Hypridle
- Setup → Config → Hyprlock
- Setup → Config → Hyprsunset
- Setup → Config → Swayosd
- Setup → Config → Walker
- Setup → Config → Waybar
- Setup → Config → XCompose

**Install (60+ items):**
- Install → Package
- Install → AUR
- Install → Web App
- Install → TUI
- Install → Service → Dropbox
- Install → Service → Tailscale
- Install → Service → Bitwarden
- Install → Service → Chromium Account
- Install → Style → Theme
- Install → Style → Background
- Install → Style → Font → Meslo LG Mono
- Install → Style → Font → Fira Code
- Install → Style → Font → Victor Code
- Install → Style → Font → Bistream Vera Mono
- Install → Style → Font → Iosevka
- Install → Development → Ruby on Rails
- Install → Development → Docker DB
- Install → Development → JavaScript → Node.js
- Install → Development → JavaScript → Bun
- Install → Development → JavaScript → Deno
- Install → Development → Go
- Install → Development → PHP
- Install → Development → Laravel
- Install → Development → Symfony
- Install → Development → Python
- Install → Development → Elixir
- Install → Development → Phoenix
- Install → Development → Zig
- Install → Development → Rust
- Install → Development → Java
- Install → Development → .NET
- Install → Development → OCaml
- Install → Development → Clojure
- Install → Editor → VSCode
- Install → Editor → Cursor
- Install → Editor → Zed
- Install → Editor → Sublime Text
- Install → Editor → Helix
- Install → Editor → Emacs
- Install → Terminal → Alacritty
- Install → Terminal → Ghostty
- Install → Terminal → Kitty
- Install → AI → Claude Code
- Install → AI → Cursor CLI
- Install → AI → Gemini
- Install → AI → OpenAI Codex
- Install → AI → LM Studio
- Install → AI → Ollama
- Install → AI → Crush
- Install → AI → opencode
- Install → Windows
- Install → Gaming → Steam
- Install → Gaming → RetroArch
- Install → Gaming → Minecraft
- Install → Gaming → Xbox Controller

**Remove (7 items):**
- Remove → Package
- Remove → Web App
- Remove → TUI
- Remove → Theme
- Remove → Windows
- Remove → Fingerprint
- Remove → Fido2

**Update (25+ items):**
- Update → Omarchy
- Update → Channel → Stable
- Update → Channel → Edge
- Update → Channel → Dev
- Update → Config → Hyprland
- Update → Config → Hypridle
- Update → Config → Hyprlock
- Update → Config → Hyprsunset
- Update → Config → Plymouth
- Update → Config → Swayosd
- Update → Config → Walker
- Update → Config → Waybar
- Update → Extra Themes
- Update → Process → Hypridle
- Update → Process → Hyprsunset
- Update → Process → Swayosd
- Update → Process → Walker
- Update → Process → Waybar
- Update → Hardware → Audio
- Update → Hardware → Wi-Fi
- Update → Hardware → Bluetooth
- Update → Firmware
- Update → Timezone
- Update → Time
- Update → Password → Drive Encryption
- Update → Password → User

**System (4 items):**
- System → Lock
- System → Screensaver
- System → Restart
- System → Shutdown

**Total:** ~180-200 actionable items

### Edge Cases & Error Handling

#### 1. Invalid Selection
If user somehow selects a malformed breadcrumb:
```bash
if [[ -z "$action_id" || "$action_id" == "$selection" ]]; then
  return 1  # Fall back to normal menu handling
fi
```

#### 2. Unknown Action ID
Fallback case in `handle_breadcrumb_selection()`:
```bash
*)
  notify-send "Omarchy Menu" "Unknown action: $action_id"
  show_main_menu
  ;;
```

#### 3. Dynamic Menu Items
Some menus check for config files before showing items (e.g., Setup menu lines 171-173). For now, include all possible items in flat map. Future optimization: generate map dynamically.

#### 4. Icon Preservation
Walker truncates long lines at 295px width. Test with longest breadcrumbs (e.g., 4-level paths) to ensure readability.

#### 5. Walker Pipe Character
If Walker interprets `|` as special character, escape it or use alternate delimiter (e.g., `::` or `##`).

### Performance Considerations

**Menu Launch Time:**
- Current: ~instant
- With flat map: +~5-10ms (cat heredoc)
- Walker search: ~instant (native binary)

**Memory:**
- Flat map: ~15KB additional text
- Negligible impact

**Optimization:**
- Use heredoc (no subprocess spawning)
- Pre-computed static list (no runtime generation)

### Testing Strategy

**Functional Testing:**
1. Launch menu: `omarchy-menu`
2. Verify top-level items appear first
3. Scroll down to verify flat items appear
4. Type "package" → verify "Install → Package" appears
5. Select → verify `omarchy-pkg-install` launches
6. Test various search terms:
   - "rails" → Install → Development → Ruby on Rails
   - "lock" → System → Lock (and Trigger → Toggle → Idle Lock)
   - "theme" → Style → Theme (and Install → Style → Theme)
7. Test top-level navigation still works (select "Install" without typing)
8. Test direct menu invocation: `omarchy-menu install`

**Edge Case Testing:**
1. Empty search (should show all items)
2. Search with no matches (Walker shows empty list)
3. Cancel menu (ESC key)
4. Very long breadcrumbs (4-level paths)

**Regression Testing:**
1. All existing menu navigation patterns
2. `BACK_TO_EXIT` mechanism
3. Direct submenu calls
4. `back_to()` function

### Backwards Compatibility

**Preserves:**
✅ All existing menu functions unchanged
✅ `go_to_menu()` backward compatible
✅ Direct menu invocation: `omarchy-menu install`
✅ `BACK_TO_EXIT` mechanism
✅ `back_to()` navigation

**Adds:**
✅ Global search capability
✅ Direct submenu access
✅ Breadcrumb navigation

**Breaking changes:** None

### Maintenance

**Adding new menu items:**
When adding new menus:
1. Add menu function (existing process)
2. Add entry to `build_flat_menu_map()`
3. Add action mapping to `handle_breadcrumb_selection()`

**Documentation needed:**
- Add comments in code explaining breadcrumb format
- Document action_id naming convention

**Future refactoring:**
Could consolidate into data-driven structure:
```bash
declare -A MENU_MAP=(
  ["learn_omarchy"]="  Learn → Omarchy|omarchy-launch-webapp https://..."
)
```

## Summary

**Solution:** Hybrid menu with flattened search overlay

**User Benefits:**
- Browse hierarchically (familiar)
- Search globally (powerful)
- No mode switching (seamless)
- Clear breadcrumbs (context)

**Developer Benefits:**
- Minimal refactoring
- Maintainable
- Extensible
- Low risk

**Implementation Effort:**
- ~2-3 hours for experienced bash developer
- ~250-300 lines of new code
- ~7 lines modified
- 0 breaking changes

**Critical Files:**
- `/home/nate/.local/share/omarchy/bin/omarchy-menu`

## Next Steps

1. Get user approval on this plan
2. Implement `build_flat_menu_map()` function
3. Implement `handle_breadcrumb_selection()` function
4. Modify `show_main_menu()` function
5. Enhance `go_to_menu()` function
6. Test thoroughly
7. Deploy to dotfiles repo
