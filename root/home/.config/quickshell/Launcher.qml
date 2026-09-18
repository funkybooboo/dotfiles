pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Widgets
import QtQuick

// Replaces hyprlauncher. Size, colours, fonts and row metrics come from
// hyprlauncher.conf and the hyprtoolkit.conf palette it read, so it looks the
// same; `show_apps_on_open = 1` is why the list is populated before any typing.
Overlay {
  id: launcher

  panelWidth: Theme.pickerWidth
  panelHeight: Theme.pickerHeight

  visible: Overlays.current === Overlays.launcher
  onDismissed: Overlays.close()

  readonly property var entries: {
    const query = search.text.trim().toLowerCase();
    const all = DesktopEntries.applications.values.filter(e => !e.noDisplay);

    if (query === "")
      return all.sort((a, b) => a.name.localeCompare(b.name));

    // Name, generic name and keywords are what a user actually types; matching
    // the Exec line as well would surface entries whose visible label has
    // nothing to do with the query.
    return all.filter(e => (e.name + " " + e.genericName + " " + e.keywords.join(" "))
      .toLowerCase()
      .includes(query))
      .sort((a, b) => a.name.localeCompare(b.name));
  }

  // Reset on show rather than in an open() function: the singleton can be toggled
  // from either caller, so the reset has to hang off the state change.
  onVisibleChanged: {
    if (!launcher.visible)
      return;

    search.text = "";
    list.currentIndex = 0;
    search.forceActiveFocus();
  }

  function launch() {
    const entry = launcher.entries[list.currentIndex];
    if (!entry)
      return;

    entry.execute();
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

      // Single-line TextInput ignores Up/Down, so they are free for the list.
      Keys.onEscapePressed: Overlays.close()
      Keys.onReturnPressed: launcher.launch()
      Keys.onEnterPressed: launcher.launch()
      Keys.onDownPressed: list.currentIndex = Math.min(list.count - 1, list.currentIndex + 1)
      Keys.onUpPressed: list.currentIndex = Math.max(0, list.currentIndex - 1)

      // Any edit invalidates the selection, so start from the top again.
      onTextChanged: list.currentIndex = 0

      Text {
        anchors.verticalCenter: parent.verticalCenter

        visible: search.text === ""
        text: "Search applications"
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
      model: launcher.entries
      currentIndex: 0
      highlightMoveDuration: 0

      delegate: Rectangle {
        required property var modelData
        required property int index

        width: list.width
        height: Theme.pickerRowHeight

        radius: Theme.roundingSmall
        color: index === list.currentIndex ? Theme.mauve : "transparent"

        Row {
          anchors {
            left: parent.left
            leftMargin: Theme.roundingSmall
            verticalCenter: parent.verticalCenter
          }

          spacing: Theme.roundingSmall

          IconImage {
            anchors.verticalCenter: parent.verticalCenter
            implicitSize: Theme.pickerIconSize
            source: Quickshell.iconPath(modelData.icon, true)
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter

            text: modelData.name
            // The selected row fills with accent, so its label flips to the dark
            // background colour to stay readable.
            color: index === list.currentIndex ? Theme.base : Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.pickerFontSize
          }
        }

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            list.currentIndex = index;
            launcher.launch();
          }
        }
      }
    }
  }
}
