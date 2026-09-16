import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick

// Replaces hyprlauncher. Size, colours, fonts and row metrics come from
// hyprlauncher.conf and the hyprtoolkit.conf palette it read, so it looks the
// same; `show_apps_on_open = 1` is why the list is populated before any typing.
//
// Overlay layer with exclusive keyboard focus: it has to sit above every window
// and take all key input while open. WlSessionLock is the right tool for a lock
// screen -- this is not one.
//
// A PanelWindow is sized by its anchors, so an unanchored one has no geometry and
// never maps. It covers the screen instead, transparent, with the panel centred
// inside -- which is also what makes clicking outside dismiss it.
PanelWindow {
  id: launcher

  screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? null

  anchors {
    top: true
    bottom: true
    left: true
    right: true
  }

  color: "transparent"
  visible: LauncherState.open

  // Fullscreen but claims nothing: without this the overlay would reserve the
  // whole screen and shove every window aside.
  exclusiveZone: 0

  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

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

  function close() {
    LauncherState.open = false;
  }

  // Reset on show rather than in an open() function: the singleton can be
  // toggled from either caller, so the reset has to hang off the state change.
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
    launcher.close();
  }

  // Click anywhere outside the panel to dismiss, the way a launcher should.
  MouseArea {
    anchors.fill: parent
    onClicked: launcher.close()
  }

  Rectangle {
    anchors.centerIn: parent

    width: Theme.launcherWidth
    height: Theme.launcherHeight

    color: Theme.mantle
    radius: Theme.roundingLarge
    border.width: 1
    border.color: Theme.mauve

    // Swallows clicks that land on the panel so they do not reach the dismiss
    // area behind it.
    MouseArea {
      anchors.fill: parent
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
        height: Theme.launcherRowHeight

        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.launcherFontSize
        verticalAlignment: TextInput.AlignVCenter
        clip: true
        focus: true

        // Single-line TextInput ignores Up/Down, so they are free for the list.
        Keys.onEscapePressed: launcher.close()
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
          font.pixelSize: Theme.launcherFontSize
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
        height: parent.height - Theme.launcherRowHeight - Theme.notificationPadding * 2 - 1

        clip: true
        model: launcher.entries
        currentIndex: 0
        highlightMoveDuration: 0

        delegate: Rectangle {
          required property var modelData
          required property int index

          width: list.width
          height: Theme.launcherRowHeight

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
              implicitSize: Theme.launcherIconSize
              source: Quickshell.iconPath(modelData.icon, true)
            }

            Text {
              anchors.verticalCenter: parent.verticalCenter

              text: modelData.name
              // The selected row fills with accent, so its label flips to the
              // dark background colour to stay readable.
              color: index === list.currentIndex ? Theme.base : Theme.text
              font.family: Theme.fontFamily
              font.pixelSize: Theme.launcherFontSize
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
}
