import Quickshell.Services.Notifications
import Quickshell.Widgets
import QtQuick

// One toast. Height follows its content rather than the fixed 110px it inherited
// from mako's config -- a body-less notification was rendering as a two-thirds
// empty box.
//
// Every toast carries a visible edge. Only critical urgency used to, which left a
// normal toast as base-on-base: invisible as a card against any dark window.
Rectangle {
  id: root

  required property var notification

  readonly property bool urgent: root.notification.urgency === NotificationUrgency.Critical
  readonly property var extraActions:
    root.notification.actions.filter(a => a.identifier !== "default")

  implicitWidth: Theme.notificationWidth
  implicitHeight: Math.max(Theme.notificationMinHeight,
    content.implicitHeight + Theme.notificationPadding * 2)

  color: Theme.mantle
  radius: Theme.roundingLarge
  border.width: Theme.separatorWidth
  border.color: root.urgent ? Theme.red : Theme.surface1
  // The fixed height used to guarantee the fit; now that it flexes, clipping is
  // what keeps a long body inside the rounded corners.
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

  Row {
    id: content

    anchors {
      left: parent.left
      right: parent.right
      top: parent.top
      margins: Theme.notificationPadding
    }

    spacing: Theme.notificationPadding

    IconImage {
      id: icon

      implicitSize: Theme.notificationIconSize
      visible: root.notification.image !== "" || root.notification.appIcon !== ""
      source: root.notification.image !== "" ? root.notification.image : root.notification.appIcon
    }

    Column {
      width: parent.width
        - (icon.visible ? Theme.notificationIconSize + Theme.notificationPadding : 0)

      spacing: Theme.notificationTextSpacing

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

      // Anything beyond the default action had no UI at all, even though the server
      // advertises actionsSupported -- so a "Reply / Mark read" notification
      // silently offered neither.
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

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    // Sits under the action buttons so their own handlers win.
    z: -1

    // Left click activates and dismisses; right click only dismisses. Previously
    // the close ran unconditionally, so there was no way to dismiss a notification
    // without also firing whatever its default action was.
    onClicked: mouse => {
      if (mouse.button === Qt.LeftButton) {
        const action = root.notification.actions.find(a => a.identifier === "default");
        if (action)
          action.invoke();
        else
          Compositor.focusWindowFor(root.notification);
      }

      Notifications.close(root.notification);
    }
  }
}
