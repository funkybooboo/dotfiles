pragma Singleton
import Quickshell

// Whether the launcher is showing. A singleton because two callers toggle it: the
// bar button, which is in this same process and should not shell out to talk to
// itself, and the Hyprland keybind, which comes in over IPC.
Singleton {
  property bool open: false

  function toggle() {
    open = !open;
  }
}
