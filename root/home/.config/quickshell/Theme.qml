pragma Singleton
import Quickshell
import QtQuick

// Catppuccin Mocha. Every value here is carried over from the waybar and mako
// configs this shell replaces, so the look does not shift during the migration.
// Deliberately not split into a data file that a script rewrites: quickshell
// live-reloads QML on save, so a separate palette file would add a layer
// without adding an ability.
Singleton {
  readonly property color base: "#1e1e2e"
  readonly property color mantle: "#181825"
  readonly property color text: "#cdd6f4"
  readonly property color mauve: "#cba6f7"
  readonly property color blue: "#89b4fa"
  readonly property color red: "#f38ba8"
  readonly property color peach: "#fab387"

  // Wallpapers are not tracked in the repo (binary, copied per machine), so this
  // is a path into $HOME rather than a repo-relative asset. hyprlock reads the
  // same file for its blurred background.
  //
  // This is the one line of the quickshell tree that differs from the work repo:
  // the two machines carry different wallpapers, exactly as hyprlock.conf already
  // hardcodes a different filename in each.
  readonly property string wallpaper: Quickshell.env("HOME") + "/Pictures/wallpapers/mountain-wallpaper.jpg"

  readonly property string fontFamily: "JetBrainsMono Nerd Font"
  readonly property int fontSize: 12

  readonly property int barHeight: 26
  readonly property int barEdgeMargin: 8
  readonly property real moduleMargin: 7.5
  readonly property int moduleMinWidth: 12

  readonly property int tooltipPadding: 6

  readonly property int notificationWidth: 350
  readonly property int notificationHeight: 110
  readonly property int notificationMargin: 10
  readonly property int notificationPadding: 12
  readonly property int notificationTimeout: 5000

  // Shared metrics for the summoned pickers, taken from hyprlauncher.conf and the
  // hyprtoolkit.conf palette it read: an 820x720 window, 15px rows, and a row
  // height of font_size * 2 + 4 with icons at 0.7 of the row.
  readonly property int pickerWidth: 820
  readonly property int pickerHeight: 720
  readonly property int pickerFontSize: 15
  readonly property int pickerRowHeight: 34
  readonly property int pickerIconSize: 24
  readonly property int roundingLarge: 10
  readonly property int roundingSmall: 6

  readonly property int trayIconSize: 12
  readonly property int traySpacing: 17

  readonly property int workspaceMinWidth: 9
  readonly property int workspacePadding: 6
  readonly property real workspaceMargin: 1.5
  readonly property color workspaceHover: Qt.rgba(mauve.r, mauve.g, mauve.b, 0.1)
}
