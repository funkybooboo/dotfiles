pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick

// Replaces hypr-window-switcher and its -inner half, which paired `hyprctl
// clients -j | jq` with fzf in a floating terminal. The window list is a live
// Wayland model here, so nothing shells out and nothing parses JSON.
//
// activate() goes through the toplevel-management protocol rather than
// `hyprctl dispatch focuswindow`, so the compositor decides how to reach the
// window -- including switching workspace for it.
Overlay {
  id: switcher

  panelWidth: Theme.pickerWidth
  panelHeight: Theme.pickerHeight

  visible: Overlays.current === Overlays.switcher
  onDismissed: Overlays.close()

  readonly property var windows: {
    const query = search.text.trim().toLowerCase();
    const all = ToplevelManager.toplevels.values;

    if (query === "")
      return all;

    return all.filter(w => (w.appId + " " + w.title).toLowerCase().includes(query));
  }

  onVisibleChanged: {
    if (!switcher.visible)
      return;

    search.text = "";
    list.currentIndex = 0;
    search.forceActiveFocus();
  }

  function focusSelected() {
    const window = switcher.windows[list.currentIndex];
    if (!window)
      return;

    window.activate();
    Overlays.close();
  }

  Column {
    anchors {
      fill: parent
      margins: Theme.notificationPadding
    }

    spacing: Theme.notificationPadding

    TextInput {
      id: search

      width: parent.width
      height: Theme.pickerRowHeight

      color: Theme.text
      font.family: Theme.fontFamily
      font.pixelSize: Theme.pickerFontSize
      verticalAlignment: TextInput.AlignVCenter
      clip: true
      focus: true

      Keys.onEscapePressed: Overlays.close()
      Keys.onReturnPressed: switcher.focusSelected()
      Keys.onEnterPressed: switcher.focusSelected()
      Keys.onDownPressed: list.currentIndex = Math.min(list.count - 1, list.currentIndex + 1)
      Keys.onUpPressed: list.currentIndex = Math.max(0, list.currentIndex - 1)

      onTextChanged: list.currentIndex = 0

      Text {
        anchors.verticalCenter: parent.verticalCenter

        visible: search.text === ""
        text: "Search windows"
        color: Theme.text
        opacity: 0.5
        font.family: Theme.fontFamily
        font.pixelSize: Theme.pickerFontSize
      }
    }

    Rectangle {
      width: parent.width
      height: 1
      color: Theme.mauve
      opacity: 0.4
    }

    ListView {
      id: list

      width: parent.width
      height: parent.height - Theme.pickerRowHeight - Theme.notificationPadding * 2 - 1

      clip: true
      model: switcher.windows
      currentIndex: 0
      highlightMoveDuration: 0

      delegate: Rectangle {
        required property var modelData
        required property int index

        readonly property bool selected: index === list.currentIndex

        width: list.width
        height: Theme.pickerRowHeight

        radius: Theme.roundingSmall
        color: selected ? Theme.mauve : "transparent"

        Row {
          anchors {
            left: parent.left
            right: parent.right
            leftMargin: Theme.roundingSmall
            rightMargin: Theme.roundingSmall
            verticalCenter: parent.verticalCenter
          }

          spacing: Theme.roundingSmall

          // The desktop entry is looked up from the app id so the row carries the
          // same icon the launcher shows; a bare app id has none.
          IconImage {
            anchors.verticalCenter: parent.verticalCenter

            implicitSize: Theme.pickerIconSize
            source: {
              const entry = DesktopEntries.heuristicLookup(modelData.appId);
              return entry ? Quickshell.iconPath(entry.icon, true) : "";
            }
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter

            text: modelData.appId
            color: selected ? Theme.base : Theme.mauve
            font.family: Theme.fontFamily
            font.pixelSize: Theme.pickerFontSize
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter

            width: list.width - 220
            text: modelData.title
            color: selected ? Theme.base : Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.pickerFontSize
            elide: Text.ElideRight
          }
        }

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            list.currentIndex = index;
            switcher.focusSelected();
          }
        }
      }
    }
  }
}
