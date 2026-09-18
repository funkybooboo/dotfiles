pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Io
import QtQuick

// Replaces the hypr-keybinds script, which rendered the same list through fzf in a
// floating terminal with its own colour scheme.
//
// Read-only on purpose. The script re-ran the selected bind on Enter, and that one
// feature is why it had to reconstruct a runnable dispatcher -- the reason its
// sibling on the Lua machine grew a 600-line Lua parser. A cheatsheet only has to
// answer "what does this key do", and modmask, key and description are reported
// whatever the config language.
Overlay {
  id: sheet

  panelWidth: Theme.pickerWidth
  panelHeight: Theme.pickerHeight

  // Each row is { combo, category, action }, pre-sorted so the ListView section
  // headers below come out grouped.
  property var rows: []

  readonly property var shown: {
    const needle = search.text.toLowerCase();
    if (needle === "")
      return sheet.rows;

    return sheet.rows.filter(r => r.combo.toLowerCase().includes(needle)
      || r.action.toLowerCase().includes(needle));
  }

  visible: Overlays.current === Overlays.cheatsheet
  onDismissed: Overlays.close()

  onVisibleChanged: {
    if (!visible)
      return;

    search.text = "";
    // Re-read every time: a reload can rebind anything, and a stale sheet is
    // worse than a slow one.
    binds.running = true;
  }

  // Derived from the bitmask rather than a lookup table of combinations. The
  // script this replaces enumerated them and had no entry for 0, so every
  // unmodified media key rendered as "0 + XF86AudioPlay".
  function modifiers(mask) {
    const names = [];
    if (mask & 64) names.push("Super");
    if (mask & 4) names.push("Ctrl");
    if (mask & 8) names.push("Alt");
    if (mask & 1) names.push("Shift");
    return names;
  }

  function parse(text) {
    const parsed = [];

    for (const bind of JSON.parse(text)) {
      const description = bind.description ?? "";
      if (description === "")
        continue;

      const split = description.indexOf(":");
      const key = bind.key !== "" ? bind.key : "code:" + bind.keycode;

      parsed.push({
        combo: sheet.modifiers(bind.modmask).concat([key]).join(" + "),
        category: split === -1 ? "Other" : description.slice(0, split),
        action: split === -1 ? description : description.slice(split + 1).trim()
      });
    }

    parsed.sort((a, b) => a.category === b.category
      ? a.action.localeCompare(b.action)
      : a.category.localeCompare(b.category));

    return parsed;
  }

  Process {
    id: binds

    command: ["hyprctl", "binds", "-j"]

    stdout: StdioCollector {
      onStreamFinished: sheet.rows = sheet.parse(this.text)
    }
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
      Keys.onDownPressed: list.contentY += Theme.pickerRowHeight
      Keys.onUpPressed: list.contentY -= Theme.pickerRowHeight

      Text {
        anchors.verticalCenter: parent.verticalCenter

        visible: search.text === ""
        text: sheet.rows.length + " keybindings -- type to filter"
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
      model: sheet.shown

      section.property: "category"
      section.criteria: ViewSection.FullString
      section.delegate: Text {
        required property string section

        width: list.width
        height: Theme.pickerRowHeight

        text: section
        color: Theme.mauve
        font.family: Theme.fontFamily
        font.pixelSize: Theme.pickerFontSize
        font.bold: true
        verticalAlignment: Text.AlignVCenter
      }

      delegate: Row {
        required property var modelData

        width: list.width
        height: Theme.pickerRowHeight

        spacing: Theme.notificationPadding

        Text {
          width: Theme.cheatsheetComboWidth

          text: modelData.combo
          color: Theme.peach
          font.family: Theme.fontFamily
          font.pixelSize: Theme.pickerFontSize
          verticalAlignment: Text.AlignVCenter
          elide: Text.ElideRight
        }

        Text {
          text: modelData.action
          color: Theme.text
          font.family: Theme.fontFamily
          font.pixelSize: Theme.pickerFontSize
          verticalAlignment: Text.AlignVCenter
          elide: Text.ElideRight
        }
      }
    }
  }
}
