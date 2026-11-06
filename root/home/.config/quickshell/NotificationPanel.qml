pragma ComponentBehavior: Bound
import QtQuick

// The notification history modal, the same chrome as the other summoned panels:
// centred on the focused monitor, click-outside or Esc dismisses, exclusive
// keyboard focus. Toasts and this panel are two views of the same list:
// everything the daemon has tracked, newest first -- the notification a
// toast's X merely hid resurfaces here, and the row's X is the only thing that
// deletes one. Silent mode changes nothing in this list, only whether the
// toast stack shows.
Overlay {
  id: panel

  panelWidth: Theme.pickerWidth
  panelHeight: Theme.pickerHeight

  visible: Overlays.current === Overlays.notificationPanel
  onDismissed: Overlays.close()

  // The base for the age labels: re-based on open, and ticked while open, so a
  // panel left open still counts. ago() re-reads it on every tick, which is
  // what keeps "now" from silently becoming "5m" without the label moving.
  property date now: new Date()

  onVisibleChanged: if (visible) panel.now = new Date()

  Timer {
    interval: 30000
    repeat: true
    running: panel.visible
    onTriggered: panel.now = new Date()
  }

  // "now" / "5m" / "2h" / "3d" -- coarse by design; the exact minute is noise in
  // a review list.
  function ago(id) {
    const received = Notifications.received[id];
    if (!received)
      return "";

    const seconds = Math.floor((panel.now.getTime() - received) / 1000);

    if (seconds < 60)
      return "now";
    if (seconds < 3600)
      return Math.floor(seconds / 60) + "m";
    if (seconds < 86400)
      return Math.floor(seconds / 3600) + "h";
    return Math.floor(seconds / 86400) + "d";
  }

  Column {
    anchors.fill: parent
    spacing: Theme.notificationPadding

    Item {
      width: parent.width
      height: Theme.pickerRowHeight

      Text {
        anchors {
          left: parent.left
          leftMargin: Theme.notificationPadding
          verticalCenter: parent.verticalCenter
        }

        text: "Notifications"
        color: Theme.mauve
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize + 1
        font.bold: true
      }

      Row {
        anchors {
          right: parent.right
          rightMargin: Theme.notificationPadding
          verticalCenter: parent.verticalCenter
        }

        spacing: Theme.notificationPadding

        Text {
          id: clear

          anchors.verticalCenter: parent.verticalCenter
          visible: Notifications.history.length > 0
          text: "Clear"
          color: clearHover.hovered ? Theme.red : Theme.subtext0
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize

          HoverHandler {
            id: clearHover
          }

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: Notifications.removeAll()
          }
        }

        // The same toggle the bar's bell performs, on the surface it governs.
        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: Notifications.doNotDisturb
            ? String.fromCodePoint(0xf1f6)
            : String.fromCodePoint(0xf0f3)
          color: dndHover.hovered ? Theme.mauve
            : (Notifications.doNotDisturb ? Theme.subtext0 : Theme.text)
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize + 1

          HoverHandler {
            id: dndHover
          }

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: Notifications.doNotDisturb = !Notifications.doNotDisturb
          }
        }
      }
    }

    Rectangle {
      width: parent.width
      height: 1
      color: Theme.mauve
      opacity: Theme.separatorOpacity
    }

    Item {
      width: parent.width
      height: parent.height
        - Theme.pickerRowHeight
        - Theme.notificationPadding * 2
        - 1

      ListView {
        id: list

        anchors.fill: parent
        clip: true
        spacing: Theme.notificationMargin
        model: Notifications.history

        // The panel owns no text input, so the list itself is the keyboard's
        // landing spot -- the same focus pattern as ActionMenu, whose Esc works.
        focus: true

        Keys.onEscapePressed: Overlays.close()

        delegate: Rectangle {
          required property var modelData

          x: Theme.notificationPadding
          width: list.width - Theme.notificationPadding * 2
          height: Math.max(Theme.notificationMinHeight,
            body.implicitHeight + Theme.notificationPadding * 2)

          radius: Theme.roundingSmall
          color: Theme.base
          clip: true

          NotificationContent {
            id: body

            notification: modelData
            metaText: panel.ago(modelData.id)
            anchors {
              left: parent.left
              right: parent.right
              top: parent.top
              margins: Theme.notificationPadding
            }
          }

          // The delete path, in the same corner the toast's close button uses.
          // Deleting a notification that is still toasting takes the toast with
          // it: they are one list.
          Item {
            id: deleteButton

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
              color: deleteHover.hovered ? Theme.red : Theme.overlay0
              font.family: Theme.fontFamily
              font.pixelSize: Theme.fontSize - 2
            }

            HoverHandler {
              id: deleteHover
            }

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: Notifications.remove(modelData)
            }
          }

          // The card body behaves like a toast: activate (the default action, or
          // a best-effort focus match), then stop showing it. The panel closes
          // too, because the activation just went somewhere else and the overlay
          // would otherwise sit on top of the destination swallowing clicks.
          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            z: -1

            onClicked: {
              Notifications.activate(modelData);
              Notifications.close(modelData);
              Overlays.close();
            }
          }
        }
      }

      Text {
        anchors.centerIn: parent
        visible: Notifications.history.length === 0
        text: "No notifications"
        color: Theme.overlay0
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
      }
    }
  }
}
