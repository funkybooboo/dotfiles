import Quickshell.Services.Notifications
import Quickshell.Widgets
import QtQuick

// One toast, sized and coloured from mako/config: 350x110, 12px padding, square
// corners, and no border except at critical urgency, where mako drew 2px in red.
Rectangle {
  id: root

  required property var notification

  readonly property bool urgent: root.notification.urgency === NotificationUrgency.Critical

  implicitWidth: Theme.notificationWidth
  implicitHeight: Theme.notificationHeight
  color: Theme.base
  border.width: root.urgent ? 2 : 0
  border.color: Theme.red

  // mako ran ignore-timeout=0, so an app's own requested timeout wins and its
  // default-timeout only applies when the app asked for none. Critical urgency had
  // default-timeout 0, meaning it stays until dismissed.
  Timer {
    interval: root.notification.expireTimeout > 0
      ? root.notification.expireTimeout
      : Theme.notificationTimeout
    running: !root.urgent
    onTriggered: Notifications.close(root.notification)
  }

  Row {
    anchors {
      fill: parent
      margins: Theme.notificationPadding
    }

    spacing: Theme.notificationPadding

    IconImage {
      id: icon

      anchors.verticalCenter: parent.verticalCenter
      implicitSize: 48
      visible: root.notification.image !== "" || root.notification.appIcon !== ""
      source: root.notification.image !== "" ? root.notification.image : root.notification.appIcon
    }

    Column {
      anchors.verticalCenter: parent.verticalCenter

      width: parent.width - (icon.visible ? 48 + Theme.notificationPadding : 0)
      spacing: 2

      Text {
        width: parent.width
        text: root.notification.appName
        color: Theme.mauve
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 1
        elide: Text.ElideRight
      }

      Text {
        width: parent.width
        text: root.notification.summary
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.bold: true
        elide: Text.ElideRight
      }

      Text {
        width: parent.width
        text: root.notification.body
        textFormat: Text.StyledText
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        wrapMode: Text.WordWrap
        maximumLineCount: 3
        elide: Text.ElideRight
      }
    }
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton

    // Left click runs the default action the way makoctl invoke did, falling back
    // to dismissing when the notification offers none.
    onClicked: mouse => {
      if (mouse.button === Qt.LeftButton) {
        const action = root.notification.actions.find(a => a.identifier === "default");
        if (action)
          action.invoke();
      }

      Notifications.close(root.notification);
    }
  }
}
