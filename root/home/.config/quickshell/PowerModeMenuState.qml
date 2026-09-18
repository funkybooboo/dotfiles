pragma Singleton
import Quickshell

// Whether the power-mode menu is showing. A singleton for the same reason as
// LauncherState: the battery bar module toggles it in-process, and the power menu
// opens it from the other side.
Singleton {
  property bool open: false

  function toggle() {
    open = !open;
  }
}
