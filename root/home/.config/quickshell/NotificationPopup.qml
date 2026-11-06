import Quickshell.Services.Notifications
import QtQuick

// One toast, geometry straight from the mako config this replaced: 350 wide, square
// corners, no border, and 2px red at critical urgency.
//
// Height follows its content, which the fixed 110px did not. mako's `height` was a
// MAXIMUM -- notifications shrank to fit -- so a hardcoded height was the
// infidelity, and a body-less notification rendered as a two-thirds empty box.
//
// Closing (X button, right-click or timeout) hides the toast; the notification
// stays in the panel's history. Only the panel deletes.
Rectangle {
  id: root

  required property var notification

  readonly property bool urgent: root.notification.urgency === NotificationUrgency.Critical

  implicitWidth: Theme.notificationWidth
  implicitHeight: Math.max(Theme.notificationMinHeight,
    body.implicitHeight + Theme.notificationPadding * 2)

  color: Theme.base
  border.width: root.urgent ? Theme.notificationUrgentBorder : 0
  border.color: Theme.red
  // The fixed height used to guarantee the fit; now that it flexes, clipping is
  // what keeps a long body inside the card.
  clip: true

  // mako ran ignore-timeout=0, so an app's own requested timeout wins and its
  // default-timeout only applies when the app asked for none. Critical urgency had
  // default-timeout 0, meaning it stays until dismissed.
  //
  // Paused while hovered: the countdown used to run regardless of the pointer, so
  // a toast could vanish mid-read.
  Timer {
    interval: root.notification.expireTimeout > 0
      ? root.notification.expireTimeout
      : Theme.notificationTimeout
    running: !root.urgent && !hover.hovered
    onTriggered: Notifications.close(root.notification)
  }

  HoverHandler {
    id: hover
  }

  NotificationContent {
    id: body

    notification: root.notification
    anchors {
      left: parent.left
      right: parent.right
      top: parent.top
      margins: Theme.notificationPadding
    }
  }

  // The visible close target the right-click already offered. NotificationContent
  // reserves the corner, so the app name never runs underneath it.
  Item {
    id: closeButton

    anchors {
      top: parent.top
      right: parent.right
      topMargin: 4
      rightMargin: 4
    }

    width: 16
    height: 16

    Text {
      anchors.centerIn: parent
      text: String.fromCodePoint(0xf00d)
      color: closeHover.hovered ? Theme.red : Theme.overlay0
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontSize - 2
    }

    HoverHandler {
      id: closeHover
    }

    MouseArea {
      anchors.fill: parent
      cursorShape: Qt.PointingHandCursor
      onClicked: Notifications.close(root.notification)
    }
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    // Sits under the close button and the action buttons so their own handlers
    // win.
    z: -1

    // Left click activates and dismisses; right click and the X only dismiss.
    // Previously the close ran unconditionally, so there was no way to dismiss a
    // notification without also firing whatever its default action was.
    onClicked: mouse => {
      if (mouse.button === Qt.LeftButton)
        Notifications.activate(root.notification);

      Notifications.close(root.notification);
    }
  }
}
