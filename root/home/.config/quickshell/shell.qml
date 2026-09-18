//@ pragma IconTheme Papirus-Dark
//@ pragma UseQApplication
//@ pragma RespectSystemStyle

import Quickshell
import Quickshell.Io

// All three pragmas above are load-bearing for the tray.
//
// IconTheme: Qt has no platform theme plugin here, so icon lookup defaults to
// hicolor and six tray icons fail to resolve -- GTK, and therefore waybar,
// walked the theme inheritance chain instead. Papirus-Dark is what
// 000321-icon-theme installs and what the GTK gsettings in autostart already
// select, so the tray matches every other app.
//
// UseQApplication: a tray item's own menu is a QtWidgets menu, so opening one
// from a QGuiApplication is refused at runtime. Most items are menu-only, which
// makes this the difference between an interactive tray and an inert one.
//
// RespectSystemStyle: quickshell otherwise unsets QT_STYLE_OVERRIDE, dropping
// that menu to Fusion's light default. This keeps Kvantum's KvDark, so the menu
// matches every other Qt app -- as waybar's tray menus followed the GTK theme.
// It cannot affect the rest of the shell, which imports no QtQuick.Controls.

// Entry point. It sits at ~/.config/quickshell/shell.qml, which quickshell
// registers as the "default" config, so a bare `quickshell` runs it and
// autostart needs no --path.
ShellRoot {
  // One bar per monitor, rebuilt as outputs come and go. The wallpaper watcher
  // service this shell replaces existed to do exactly that for hyprpaper, by
  // polling `hyprctl monitors` from a shell loop.
  Variants {
    model: Quickshell.screens

    Background {}
  }

  Variants {
    model: Quickshell.screens

    Bar {}
  }

  NotificationLayer {}

  Launcher {}

  Clipboard {}

  Switcher {}

  PowerMenu {}

  PowerModeMenu {}

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
      Media.stepVolume(step === 0 ? Media.defaultStep : step);
      return Math.round(Media.volume * 100) + "%";
    }

    function mute(): string {
      Media.toggleMute();
      return Media.muted ? "muted" : "unmuted";
    }

    function micMute(): string {
      Media.toggleMicMute();
      return Media.micMuted ? "muted" : "unmuted";
    }

    function brightness(step: int): string {
      Media.stepBrightness(step === 0 ? Media.defaultStep : step);
      return "ok";
    }

    function launcher(): string {
      LauncherState.toggle();
      return LauncherState.open ? "opened" : "closed";
    }

    function clipboard(): string {
      ClipboardState.toggle();
      return ClipboardState.open ? "opened" : "closed";
    }

    function switcher(): string {
      SwitcherState.toggle();
      return SwitcherState.open ? "opened" : "closed";
    }

    function powerMenu(): string {
      PowerMenuState.toggle();
      return PowerMenuState.open ? "opened" : "closed";
    }

    function powerMode(): string {
      PowerModeMenuState.toggle();
      return PowerModeMenuState.open ? "opened" : "closed";
    }

    function dnd(): string {
      Notifications.doNotDisturb = !Notifications.doNotDisturb;
      return Notifications.doNotDisturb ? "on" : "off";
    }
  }
}
