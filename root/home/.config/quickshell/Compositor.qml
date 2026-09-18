pragma Singleton
import Quickshell
import Quickshell.Hyprland

// The one place this shell dispatches to the compositor, and the only file that
// differs from the work repo's copy for a mechanical reason.
//
// This machine runs the Lua config, whose IPC evaluates requests as Lua
// expressions. Quickshell 0.3.1's Hyprland.dispatch still sends the dead legacy
// frame, which silently no-ops here, so every dispatch shells out to hyprctl with a
// Lua dispatcher expression -- the same form the hypr-* scripts in ~/.local/bin
// use. The work repo's copy calls Hyprland.dispatch directly.
//
// Keeping it behind this shim is what lets every caller stay byte-identical across
// the two repos.
Singleton {
  function focusWorkspace(id) {
    Quickshell.execDetached([
      "hyprctl", "dispatch", "hl.dsp.focus({workspace=" + id + "})"
    ]);
  }

  // Best effort, and it says so: a notification carries an app name and maybe a
  // desktop entry, neither of which is obliged to match a window class. Returns
  // false when nothing matched so the caller can fall back rather than silently
  // appear to have acted.
  function focusWindowFor(notification) {
    const wanted = [notification.desktopEntry, notification.appName]
      .filter(name => name)
      .map(name => name.replace(/\.desktop$/, "").toLowerCase());

    if (wanted.length === 0)
      return false;

    for (const toplevel of Hyprland.toplevels.values) {
      // lastIpcObject is the raw `hyprctl clients` entry, which is where class and
      // initialClass live; the Wayland appId is the fallback for windows Hyprland
      // has not reported a class for.
      const ipc = toplevel.lastIpcObject ?? {};
      const classes = [ipc.class, ipc.initialClass, toplevel.wayland?.appId]
        .filter(name => name)
        .map(name => name.toLowerCase());

      // Substring either way: "org.mozilla.firefox" should match "firefox", and a
      // desktop entry is frequently the longer of the two.
      const hit = classes.some(cls => wanted.some(
        name => cls === name || cls.includes(name) || name.includes(cls)));

      if (hit) {
        // Window selectors need the "address:" prefix -- hyprctl reports a bare
        // 0x..., which does not resolve on its own.
        Quickshell.execDetached([
          "hyprctl", "dispatch",
          'hl.dsp.focus({window="address:' + toplevel.address + '"})'
        ]);
        return true;
      }
    }

    return false;
  }
}
