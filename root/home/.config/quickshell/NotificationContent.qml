pragma ComponentBehavior: Bound
import Quickshell.Widgets
import QtQuick

// The shared body of a notification: icon, app name, summary, body and the
// sender's own action buttons. The toast and the panel row both render this so
// the two surfaces cannot drift apart.
//
// The caller sets the width and positions the item; the height follows the
// content, which is what lets a toast shrink to fit and a panel row grow.
Item {
  id: root

  required property var notification

  // A dimmed right-aligned label on the app-name row: the panel passes a
  // relative age, the toast nothing. Both surfaces put a close or delete button
  // in that corner, which is why the app name reserves the right edge below.
  property string metaText: ""

  readonly property var extraActions:
    root.notification.actions.filter(a => a.identifier !== "default")

  implicitHeight: content.implicitHeight

  Row {
    id: content

    anchors {
      left: parent.left
      right: parent.right
      top: parent.top
    }

    spacing: Theme.notificationPadding

    IconImage {
      id: icon

      implicitSize: Theme.notificationIconSize
      anchors.verticalCenter: parent.verticalCenter
      visible: root.notification.image !== "" || root.notification.appIcon !== ""
      source: root.notification.image !== "" ? root.notification.image : root.notification.appIcon
    }

    Column {
      width: parent.width
        - (icon.visible ? Theme.notificationIconSize + Theme.notificationPadding : 0)

      spacing: Theme.notificationTextSpacing

      Row {
        width: parent.width
        spacing: Theme.notificationTextSpacing

        Text {
          width: parent.width
            - (meta.visible ? meta.implicitWidth + Theme.notificationTextSpacing : 0)
            - Theme.notificationCloseReserve

          text: root.notification.appName
          color: Theme.mauve
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize - 1
          elide: Text.ElideRight
        }

        Text {
          id: meta

          anchors.verticalCenter: parent.verticalCenter
          visible: root.metaText !== ""
          text: root.metaText
          color: Theme.overlay0
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize - 1
        }
      }

      Text {
        width: parent.width
        text: root.notification.summary
        // Matches the body's StyledText rather than defaulting to AutoText, which
        // guessed per-string and could render one toast's summary as markup.
        textFormat: Text.StyledText
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.bold: true
        elide: Text.ElideRight
      }

      Text {
        width: parent.width
        visible: root.notification.body !== ""
        text: root.notification.body
        textFormat: Text.StyledText
        color: Theme.subtext0
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        wrapMode: Text.WordWrap
        maximumLineCount: 3
        elide: Text.ElideRight
      }

      // Anything beyond the default action had no UI at all, even though the
      // server advertises actionsSupported -- so a "Reply / Mark read"
      // notification silently offered neither.
      Row {
        visible: root.extraActions.length > 0
        spacing: Theme.notificationTextSpacing
        topPadding: Theme.notificationTextSpacing

        Repeater {
          model: root.extraActions

          Rectangle {
            required property var modelData

            implicitWidth: actionLabel.implicitWidth + Theme.notificationPadding
            implicitHeight: actionLabel.implicitHeight + Theme.notificationTextSpacing * 2

            radius: Theme.roundingSmall
            color: actionHover.hovered ? Theme.surface1 : Theme.surface0

            HoverHandler {
              id: actionHover
            }

            Text {
              id: actionLabel

              anchors.centerIn: parent
              text: modelData.text
              color: Theme.text
              font.family: Theme.fontFamily
              font.pixelSize: Theme.fontSize - 1
            }

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                modelData.invoke();
                Notifications.close(root.notification);
              }
            }
          }
        }
      }
    }
  }
}
