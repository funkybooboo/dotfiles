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
      model: Notifications.visible

      NotificationPopup {
        required property var modelData

        notification: modelData
      }
    }
  }
}
