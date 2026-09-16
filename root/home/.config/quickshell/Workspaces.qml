import Quickshell
import Quickshell.Hyprland
import QtQuick

// Ports waybar's hyprland/workspaces module. Ten buttons are always drawn --
// waybar did that with persistent-workspaces -- so the row never reflows as
// workspaces appear and disappear.
Row {
  id: root

  spacing: Theme.workspaceMargin * 2

  Repeater {
    model: 10

    Item {
      id: button

      required property int index

      readonly property int workspaceId: index + 1
      readonly property var workspace: Hyprland.workspaces.values.find(w => w.id === button.workspaceId) ?? null
      readonly property bool occupied: button.workspace !== null && button.workspace.toplevels.values.length > 0
      // Follows the focused monitor -- the one the mouse is on -- so every bar
      // highlights the same workspace. Not HyprlandWorkspace.active, which is true
      // on every output at once and lights up four workspaces per bar here, and
      // not the bar's own monitor, which would make each bar disagree.
      readonly property bool active: Hyprland.focusedWorkspace?.id === button.workspaceId

      implicitWidth: Math.max(Theme.workspaceMinWidth, label.implicitWidth) + Theme.workspacePadding * 2
      implicitHeight: Theme.barHeight

      // waybar dimmed workspaces with nothing on them via `button.empty`.
      opacity: button.occupied || button.active ? 1.0 : 0.5

      Rectangle {
        anchors.fill: parent
        color: mouse.containsMouse ? Theme.workspaceHover : "transparent"
      }

      Text {
        id: label

        anchors.centerIn: parent

        // waybar's format-icons mapped workspace 10 to "0" and whichever
        // workspace is active to a filled glyph instead of its digit.
        text: button.active
          ? String.fromCodePoint(0xf14fb)
          : (button.workspaceId === 10 ? "0" : String(button.workspaceId))
        color: button.active ? Theme.mauve : Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
      }

      MouseArea {
        id: mouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Hyprland.dispatch("workspace " + button.workspaceId)
      }
    }
  }
}
