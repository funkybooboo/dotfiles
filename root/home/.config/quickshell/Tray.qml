pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick

// Ports waybar's group/tray-expander: a chevron, dimmed while collapsed, that
// reveals the tray items.
//
// The items are interactive, as they were in waybar: left click activates, middle
// click is the secondary action, and right click opens the application's own menu.
// display() hands the menu to the item itself rather than rebuilding it from the
// DBusMenu, so submenus and checkboxes behave the way each app intends.
Row {
  id: root

  // No spacing: the drawer owns its own leading gap, so a collapsed drawer really
  // is zero width. Row spacing around a zero-width child would leave a visible
  // hole and make that gap pop in as the drawer opens.
  spacing: 0

  // Reveals on hover rather than on click. The handler covers the whole row, and
  // the row grows as the drawer opens, so moving from the chevron onto the icons
  // keeps the pointer inside it -- scoping the hover to the chevron alone would
  // collapse the drawer the moment you reached for an icon.
  readonly property bool expanded: hover.hovered

  HoverHandler {
    id: hover
  }

  BarButton {
    anchors.verticalCenter: parent.verticalCenter
    text: String.fromCodePoint(0xf053)
    opacity: root.expanded ? 1.0 : 0.5
  }

  Item {
    id: drawer

    anchors.verticalCenter: parent.verticalCenter

    implicitHeight: Theme.barHeight
    implicitWidth: content.implicitWidth + Theme.traySpacing
    width: root.expanded ? drawer.implicitWidth : 0
    // The Row keeps its own implicit width, so without clipping the icons would
    // still paint while the drawer is collapsed to zero width. Clipping is also
    // what turns the width animation below into a reveal rather than a squeeze.
    clip: true

    Behavior on width {
      NumberAnimation {
        duration: 150
        easing.type: Easing.OutQuint
      }
    }

    Row {
      id: content

      anchors {
        verticalCenter: parent.verticalCenter
        left: parent.left
        leftMargin: Theme.traySpacing
      }

      spacing: Theme.traySpacing

      Repeater {
        model: SystemTray.items

        MouseArea {
          id: item

          required property var modelData

          implicitWidth: Theme.trayIconSize
          implicitHeight: Theme.trayIconSize
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton

          onClicked: mouse => {
            const window = root.QsWindow.window;

            if (mouse.button === Qt.RightButton || item.modelData.onlyMenu) {
              const position = window.itemPosition(item);
              item.modelData.display(window, position.x, Theme.barHeight);
            } else if (mouse.button === Qt.MiddleButton) {
              item.modelData.secondaryActivate();
            } else {
              item.modelData.activate();
            }
          }

          IconImage {
            anchors.fill: parent
            source: item.modelData.icon
          }

          LazyLoader {
            active: item.containsMouse && item.modelData.tooltipTitle !== ""

            Tooltip {
              anchorItem: item
              text: item.modelData.tooltipTitle
            }
          }
        }
      }
    }
  }
}
