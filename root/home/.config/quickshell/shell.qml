//@ pragma IconTheme Papirus-Dark

import Quickshell
import Quickshell.Io

// The pragma above is load-bearing for the tray. Qt has no platform theme plugin
// here, so icon lookup defaults to hicolor and six tray icons fail to resolve --
// GTK, and therefore waybar, walked the theme inheritance chain instead.
// Papirus-Dark is what 000321-icon-theme installs and what the GTK gsettings in
// autostart already select, so the tray matches every other app.

// Entry point. It sits at ~/.config/quickshell/shell.qml, which quickshell
// registers as the "default" config, so a bare `quickshell` runs it and
// autostart needs no --path.
ShellRoot {
  // One bar per monitor, rebuilt as outputs come and go. The wallpaper watcher
  // service this shell replaces existed to do exactly that for hyprpaper, by
  // polling `hyprctl monitors` from a shell loop.
  Variants {
    model: Quickshell.screens

    Bar {}
  }

  NotificationLayer {}

  OsdLayer {}

  // One process now owns what nine daemons used to, and none of the old probes
  // reach it: `pgrep mako`, `makoctl`, `brightnessctl -m` and friends said whether
  // each daemon was alive and what it thought. This is the replacement, and it is
  // also what the Hyprland keybinds will call once the panels land.
  //
  // Query with: quickshell ipc call shell status
  IpcHandler {
    target: "shell"

    function status(): string {
      return "screens=" + Quickshell.screens.length
        + " notifications=" + Notifications.visible.length
        + " retained=" + Notifications.closedIds.length
        + " dnd=" + Notifications.doNotDisturb
        + " cpu=" + SystemMetrics.cpuPercent + "%"
        + " memory=" + SystemMetrics.memoryPercent + "%"
        + " disk=" + SystemMetrics.diskPercent + "%"
        + " down=" + SystemMetrics.downBits
        + " up=" + SystemMetrics.upBits;
    }

    // Replaces the makoctl calls the Hyprland keybinds make today.
    function dismiss(): string {
      const list = Notifications.visible;
      if (list.length === 0)
        return "none";

      Notifications.close(list[list.length - 1]);
      return "ok";
    }

    function dismissAll(): string {
      Notifications.closeAll();
      return "ok";
    }

    function restore(): string {
      return Notifications.restore() ? "ok" : "none";
    }

    function invoke(): string {
      return Notifications.invoke() ? "ok" : "none";
    }

    // Replaces the media-keys script. Steps are percent, signed, so one function
    // covers raise and lower; 0 means use the old script's 5% default.
    function volume(step: int): string {
      Osd.stepVolume(step === 0 ? Osd.defaultStep : step);
      return Math.round(Osd.volume * 100) + "%";
    }

    function mute(): string {
      Osd.toggleMute();
      return Osd.muted ? "muted" : "unmuted";
    }

    function micMute(): string {
      Osd.toggleMicMute();
      return Osd.micMuted ? "muted" : "unmuted";
    }

    function brightness(step: int): string {
      Osd.stepBrightness(step === 0 ? Osd.defaultStep : step);
      return "ok";
    }

    function dnd(): string {
      Notifications.doNotDisturb = !Notifications.doNotDisturb;
      return Notifications.doNotDisturb ? "on" : "off";
    }
  }
}
