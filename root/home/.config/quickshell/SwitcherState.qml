pragma Singleton
import Quickshell

// Whether the window switcher is showing. A singleton for the same reason as
// LauncherState and ClipboardState: the bar button toggles it in-process while the
// Hyprland keybind arrives over IPC.
Singleton {
  property bool open: false

  function toggle() {
    open = !open;
  }
}
