import Quickshell
import QtQuick

// The shape most of the old waybar modules had: a label you can click.
// Geometry mirrors waybar's shared module rule -- min-width 12px, margin 0 7.5px
// -- so the bar's spacing is unchanged.
Item {
  id: root

  property string text
  property color textColor: Theme.text
  property bool bold: false

  // Empty means no tooltip, matching waybar's `"tooltip": false` modules.
  property string tooltip: ""

  signal clicked
  signal rightClicked

  implicitWidth: Math.max(Theme.moduleMinWidth, label.implicitWidth) + Theme.moduleMargin * 2
  implicitHeight: Theme.barHeight

  Text {
    id: label

    anchors.centerIn: parent
    text: root.text
    color: root.textColor
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    font.bold: root.bold
  }

  MouseArea {
    id: mouse

    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: mouse => mouse.button === Qt.RightButton ? root.rightClicked() : root.clicked()
  }

  // Built only while hovered, so twenty modules across four monitors never hold
  // eighty popup windows open.
  LazyLoader {
    active: mouse.containsMouse && root.tooltip !== ""

    Tooltip {
      anchorItem: root
      text: root.tooltip
    }
  }
}
