pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Hyprland
import QtQuick

// The toast stack. mako anchored top-right on the focused output and showed each
// notification once, so this follows the focused monitor rather than drawing a
// copy per screen.
PanelWindow {
  id: layer

  screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? null

  anchors {
    top: true
    right: true
  }

  // Sized to its contents: a layer surface covering more than the toasts would
  // swallow clicks meant for the windows underneath.
  implicitWidth: Theme.notificationWidth + Theme.notificationMargin * 2
  implicitHeight: Math.max(1, stack.implicitHeight + Theme.notificationMargin * 2)

  color: "transparent"
  visible: !Notifications.doNotDisturb && Notifications.visible.length > 0

  // Never reserve screen space: mako's toasts floated over windows rather than
  // pushing them aside the way the bar does.
  exclusiveZone: 0

  Column {
    id: stack

    anchors {
      top: parent.top
      right: parent.right
      margins: Theme.notificationMargin
    }

    spacing: Theme.notificationMargin

    Repeater {
      // Capped at mako's max-visible default. Nothing enforced it before:
      // retainedLimit bounds only the closed-list bookkeeping, and critical urgency
      // never auto-expires, so a burst of them grew this Column off the bottom of
      // the screen with no way to see how many were hidden.
      model: Notifications.visible.slice(0, Theme.notificationMaxVisible)

      NotificationPopup {
        required property var modelData

        notification: modelData
      }
    }

    Rectangle {
      readonly property int hidden:
        Notifications.visible.length - Theme.notificationMaxVisible

      implicitWidth: Theme.notificationWidth
      implicitHeight: overflowLabel.implicitHeight + Theme.notificationPadding
      visible: hidden > 0
      color: Theme.base

      Text {
        id: overflowLabel

        anchors.centerIn: parent
        text: parent.hidden + " more"
        color: Theme.subtext0
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 1
      }

      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Notifications.closeAll()
      }
    }
  }
}
