import Quickshell
import Quickshell.Io

// Replaces the power-mode-menu script, which printed the current profile and read
// a digit from a ghostty TUI. powerprofilesctl still owns the setting.
ActionMenu {
  id: menu

  // Index order is the wire order: the label IS the powerprofilesctl profile name.
  actions: [
    { label: "performance" },
    { label: "balanced" },
    { label: "power-saver" }
  ]

  visible: Overlays.current === Overlays.powerMode
  onDismissed: Overlays.close()

  // Re-read on open rather than polling: the profile only changes through this
  // menu or a deliberate CLI call, and a stale mark is worse than a late one.
  onVisibleChanged: if (visible) probe.running = true

  onActivated: index => {
    Overlays.close();
    setter.command = ["powerprofilesctl", "set", menu.actions[index].label];
    setter.running = true;
  }

  Process {
    id: probe

    command: ["powerprofilesctl", "get"]

    stdout: StdioCollector {
      onStreamFinished: {
        const profile = this.text.trim();
        menu.markedIndex = menu.actions.findIndex(a => a.label === profile);
      }
    }
  }

  Process {
    id: setter

    // Re-probe after setting so the mark is right if the menu is reopened before
    // anything else reads the profile.
    onExited: probe.running = true
  }
}
