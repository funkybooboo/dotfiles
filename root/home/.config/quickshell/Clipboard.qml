import Quickshell
import Quickshell.Io
import QtQuick

// Replaces the clipboard-manager script, which piped `cliphist list` through fzf
// in a floating terminal. cliphist still owns the history -- quickshell has no
// clipboard API and wl-paste is what feeds the store -- so this only replaces the
// picker.
Overlay {
  id: clipboard

  panelWidth: Theme.pickerWidth
  panelHeight: Theme.pickerHeight

  visible: ClipboardState.open
  onDismissed: ClipboardState.open = false

  // Each `cliphist list` line is "<id>\t<single-line preview>".
  property var entries: []

  readonly property var shown: {
    const query = search.text.trim().toLowerCase();
    if (query === "")
      return clipboard.entries;

    return clipboard.entries.filter(e => e.preview.toLowerCase().includes(query));
  }

  // Re-read on every show: the history changes constantly, so a list cached from
  // the last time the picker was open would be stale before it was seen.
  onVisibleChanged: {
    if (!clipboard.visible)
      return;

    search.text = "";
    list.currentIndex = 0;
    lister.running = true;
    search.forceActiveFocus();
  }

  Process {
    id: lister

    command: ["cliphist", "list"]

    stdout: StdioCollector {
      id: listed

      onStreamFinished: {
        clipboard.entries = listed.text.split("\n")
          .filter(line => line.includes("\t"))
          .map(line => {
            const tab = line.indexOf("\t");
            return {
              id: line.slice(0, tab),
              preview: line.slice(tab + 1)
            };
          });
      }
    }
  }

  Process {
    id: copier
  }

  function copy() {
    const entry = clipboard.shown[list.currentIndex];
    if (!entry)
      return;

    // A shell runs the pipe because wl-copy reads the payload on stdin and
    // quickshell has no clipboard API to hand it to directly. The id is the
    // numeric key cliphist printed, so nothing user-supplied is interpolated.
    copier.command = ["sh", "-c", "cliphist decode " + entry.id + " | wl-copy"];
    copier.running = true;

    ClipboardState.open = false;
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

      Keys.onEscapePressed: ClipboardState.open = false
      Keys.onReturnPressed: clipboard.copy()
      Keys.onEnterPressed: clipboard.copy()
      Keys.onDownPressed: list.currentIndex = Math.min(list.count - 1, list.currentIndex + 1)
      Keys.onUpPressed: list.currentIndex = Math.max(0, list.currentIndex - 1)

      onTextChanged: list.currentIndex = 0

      Text {
        anchors.verticalCenter: parent.verticalCenter

        visible: search.text === ""
        text: "Search clipboard history"
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
      model: clipboard.shown
      currentIndex: 0
      highlightMoveDuration: 0

      delegate: Rectangle {
        required property var modelData
        required property int index

        width: list.width
        height: Theme.pickerRowHeight

        radius: Theme.roundingSmall
        color: index === list.currentIndex ? Theme.mauve : "transparent"

        Text {
          anchors {
            left: parent.left
            right: parent.right
            leftMargin: Theme.roundingSmall
            rightMargin: Theme.roundingSmall
            verticalCenter: parent.verticalCenter
          }

          text: modelData.preview
          color: index === list.currentIndex ? Theme.base : Theme.text
          font.family: Theme.fontFamily
          font.pixelSize: Theme.pickerFontSize
          elide: Text.ElideRight
        }

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            list.currentIndex = index;
            clipboard.copy();
          }
        }
      }
    }
  }
}
