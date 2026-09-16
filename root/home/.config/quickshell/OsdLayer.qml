import Quickshell
import Quickshell.Hyprland
import QtQuick

// The volume/brightness popup. Bottom-centre on the focused monitor, because
// there was no previous OSD to match: swayosd was removed from this setup before
// quickshell, so nothing here establishes a position.
PanelWindow {
  id: layer

  screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? null

  anchors.bottom: true
  margins.bottom: Theme.osdMargin

  implicitWidth: Theme.osdWidth
  implicitHeight: Theme.osdHeight

  color: Theme.base
  visible: Osd.kind !== ""

  // Transient and non-interactive: an empty input mask keeps it from stealing
  // clicks from whatever it floats over.
  mask: Region {}

  // Never reserve space; the bar is the only surface that should push windows.
  exclusiveZone: 0

  readonly property int percent: Osd.kind === "brightness"
    ? SystemMetrics.brightnessPercent
    : Math.round(Osd.volume * 100)

  readonly property int glyph: {
    if (Osd.kind === "brightness")
      return layer.percent < 50 ? 0xf00de : 0xf00df;
    if (Osd.muted)
      return 0xf075f;
    return layer.percent < 34 ? 0xf026 : (layer.percent < 67 ? 0xf027 : 0xf028);
  }

  Row {
    anchors {
      fill: parent
      margins: Theme.notificationPadding
    }

    spacing: Theme.notificationPadding

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: String.fromCodePoint(layer.glyph)
      color: Theme.text
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontSize * 1.5
    }

    // Fill drawn over a track rather than as a progress bar control, so the
    // colours come from the same palette as everything else.
    Rectangle {
      anchors.verticalCenter: parent.verticalCenter

      width: parent.width - 90
      height: 6
      color: Theme.mantle

      Rectangle {
        // Volume can exceed 100% (boost), so the fill is clamped rather than
        // allowed to overrun the track.
        width: parent.width * Math.min(1, layer.percent / 100)
        height: parent.height
        color: Osd.muted && Osd.kind === "volume" ? Theme.red : Theme.mauve
      }
    }

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: layer.percent + "%"
      color: Theme.text
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontSize
    }
  }
}
