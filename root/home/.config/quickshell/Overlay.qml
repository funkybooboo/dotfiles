import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick

// Shared chrome for the shell's summoned panels: a transparent full-screen layer
// on the focused monitor with one centred, rounded panel. Children are placed
// inside that panel.
//
// Full-screen for two reasons. A PanelWindow is sized by its anchors, so an
// unanchored one has no geometry and silently never maps; and covering the screen
// is what makes a click outside the panel dismiss it.
PanelWindow {
  id: overlay

  required property int panelWidth
  required property int panelHeight

  default property alias content: panel.data

  signal dismissed

  screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? null

  anchors {
    top: true
    bottom: true
    left: true
    right: true
  }

  color: "transparent"

  // Full-screen but claims nothing: without this the overlay would reserve the
  // whole screen and shove every window aside.
  exclusiveZone: 0

  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: overlay.visible
    ? WlrKeyboardFocus.Exclusive
    : WlrKeyboardFocus.None

  MouseArea {
    anchors.fill: parent
    onClicked: overlay.dismissed()
  }

  Rectangle {
    id: panel

    anchors.centerIn: parent

    width: overlay.panelWidth
    height: overlay.panelHeight

    color: Theme.mantle
    radius: Theme.roundingLarge
    border.width: 1
    border.color: Theme.mauve

    // Swallows clicks landing on the panel so they never reach the dismiss area
    // behind it.
    MouseArea {
      anchors.fill: parent
    }
  }
}
