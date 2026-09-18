pragma Singleton
import Quickshell

// Whether the power menu is showing. A singleton for the same reason as
// LauncherState: the bar button toggles it in-process while the Hyprland keybind
// arrives over IPC.
Singleton {
  property bool open: false

  function toggle() {
    open = !open;
  }
}
