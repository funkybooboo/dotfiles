import Quickshell

// Replaces the power-menu script, which read a single letter from a ghostty TUI.
ActionMenu {
  id: menu

  // Least to most destructive, so the row selected on open is always recoverable.
  // The power-mode row opens the other menu rather than running anything.
  readonly property var commands: [
    ["uwsm", "app", "--", "hyprlock"],
    ["systemctl", "suspend"],
    [],
    ["uwsm", "stop"],
    ["systemctl", "reboot"],
    ["systemctl", "poweroff"]
  ]

  actions: [
    { label: "Lock screen" },
    { label: "Suspend" },
    { label: "Power mode..." },
    { label: "Log out" },
    { label: "Restart", destructive: true },
    { label: "Shut down", destructive: true }
  ]

  visible: Overlays.current === Overlays.powerMenu
  onDismissed: Overlays.close()

  onActivated: index => {
    Overlays.close();

    if (menu.commands[index].length === 0) {
      Overlays.current = Overlays.powerMode;
      return;
    }

    Quickshell.execDetached(menu.commands[index]);
  }
}
