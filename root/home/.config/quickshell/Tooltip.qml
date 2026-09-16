import Quickshell
import QtQuick

// waybar's tooltips were GTK windows that inherited its global `*` rule, so they
// took the bar's own background, text colour and font with square corners. Text
// is StyledText because several of the ported tooltips carry markup, as waybar's
// pango strings did.
PopupWindow {
  id: root

  required property Item anchorItem
  required property string text

  // Anchored to the item rather than positioned by hand: the anchor derives its
  // window and applies the compositor's own edge adjustment, so a wide tooltip on
  // an edge module slides into view instead of being clipped. The older
  // parentWindow/relativeX properties are deprecated and silently never map.
  anchor {
    item: root.anchorItem
    edges: Edges.Bottom
    gravity: Edges.Bottom
  }

  implicitWidth: label.implicitWidth + Theme.tooltipPadding * 2
  implicitHeight: label.implicitHeight + Theme.tooltipPadding * 2
  color: Theme.base
  visible: true

  Text {
    id: label

    anchors.centerIn: parent
    text: root.text
    textFormat: Text.StyledText
    color: Theme.text
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
  }
}
