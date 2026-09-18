pragma Singleton
import Quickshell

// Which summoned surface is showing, if any.
//
// One singleton rather than one per surface, because the surfaces are mutually
// exclusive: each is a full-screen layer that takes exclusive keyboard focus, so
// two open at once stack and both claim the keyboard. Holding a single name makes
// that impossible instead of merely discouraged.
//
// A singleton because two callers reach it: the bar buttons, which are in this
// process and should not shell out to talk to themselves, and the Hyprland
// keybinds, which arrive over IPC.
Singleton {
  // One of the names below, or "" when nothing is showing.
  readonly property string launcher: "launcher"
  readonly property string switcher: "switcher"
  readonly property string clipboard: "clipboard"
  readonly property string powerMenu: "powerMenu"
  readonly property string powerMode: "powerMode"
  readonly property string cheatsheet: "cheatsheet"

  property string current: ""

  function toggle(name) {
    current = current === name ? "" : name;
  }

  function close() {
    current = "";
  }
}
