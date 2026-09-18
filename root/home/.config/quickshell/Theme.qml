pragma Singleton
import Quickshell
import QtQuick

// Catppuccin Mocha. Every value here is carried over from the waybar and mako
// configs this shell replaces, so the look does not shift during the migration.
// Deliberately not split into a data file that a script rewrites: quickshell
// live-reloads QML on save, so a separate palette file would add a layer
// without adding an ability.
Singleton {
  // Surfaces, darkest to lightest. crust sits under base for edges and shadows;
  // surface0-2 are the only tones available for a raised element or a divider, and
  // their absence is why the bar had no way to draw a separator or a card edge.
  readonly property color crust: "#11111b"
  readonly property color mantle: "#181825"
  readonly property color base: "#1e1e2e"
  readonly property color surface0: "#313244"
  readonly property color surface1: "#45475a"
  readonly property color surface2: "#585b70"

  // Foregrounds, brightest to dimmest.
  readonly property color text: "#cdd6f4"
  readonly property color subtext1: "#bac2de"
  readonly property color subtext0: "#a6adc8"
  readonly property color overlay2: "#9399b2"
  readonly property color overlay1: "#7f849c"
  readonly property color overlay0: "#6c7086"

  // Accents. mauve is reserved for "highlighted or interactive" and must not be
  // used as a state colour; green/yellow/red are the three state tiers, and peach
  // sits between yellow and red where a fourth step reads better than a jump.
  readonly property color mauve: "#cba6f7"
  readonly property color green: "#a6e3a1"
  readonly property color yellow: "#f9e2af"
  readonly property color peach: "#fab387"
  readonly property color red: "#f38ba8"
  readonly property color blue: "#89b4fa"

  // The dimmed convention, previously a raw 0.5 hand-copied into six files.
  readonly property real dimmedOpacity: 0.5

  // Wallpapers are not tracked in the repo (binary, copied per machine), so this
  // is a path into $HOME rather than a repo-relative asset. hyprlock reads the
  // same file for its blurred background.
  //
  // One of three deliberate differences from the work repo's copy of this tree,
  // alongside Bar.qml's wifi client and Compositor.qml's dispatch dialect.
  readonly property string wallpaper: Quickshell.env("HOME") + "/Pictures/wallpapers/mountain-wallpaper.jpg"

  readonly property string fontFamily: "JetBrainsMono Nerd Font"
  readonly property int fontSize: 12

  readonly property int barHeight: 26
  readonly property int barEdgeMargin: 8
  // Per-module padding. Reduced from 7.5 now that the group and cluster spacings
  // below carry the separation, so overall density is unchanged rather than wider.
  readonly property real moduleMargin: 4
  readonly property int moduleMinWidth: 12

  // Two spacing scales are what turn fourteen equal items into five groups: tight
  // inside a cluster, wider either side of a separator.
  readonly property int groupSpacing: 2
  readonly property int clusterSpacing: 10
  readonly property int separatorWidth: 1
  readonly property real separatorOpacity: 0.4

  readonly property int tooltipPadding: 6

  // Thresholds live here so the colour and the number that triggers it are not
  // three lines apart in different files.
  readonly property int batteryCriticalPercent: 10
  readonly property int batteryLowPercent: 20
  readonly property int diskCriticalPercent: 90
  readonly property int diskWarnPercent: 80
  readonly property int cpuCriticalPercent: 90
  readonly property int cpuWarnPercent: 70

  readonly property int notificationWidth: 350
  // A floor only for near-empty cards, not a size: anything with a body or an icon
  // is taller than this and grows with its content.
  readonly property int notificationMinHeight: 56
  readonly property int notificationMargin: 10
  readonly property int notificationPadding: 12
  readonly property int notificationTimeout: 5000
  readonly property int notificationIconSize: 48
  readonly property int notificationTextSpacing: 2
  readonly property int notificationMaxVisible: 5

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

  // The power menu sizes its own height from its row count, so only width is fixed.
  readonly property int menuWidth: 320

  // Wide enough for the longest chord in the binds, 29 characters
  // ("Shift + XF86MonBrightnessDown"), plus headroom at pickerFontSize.
  readonly property int cheatsheetComboWidth: 280

  readonly property int trayIconSize: 12
  readonly property int traySpacing: 17

  readonly property int workspaceMinWidth: 9
  readonly property int workspacePadding: 6
  readonly property real workspaceMargin: 1.5
  readonly property color workspaceHover: Qt.rgba(mauve.r, mauve.g, mauve.b, 0.1)
}
