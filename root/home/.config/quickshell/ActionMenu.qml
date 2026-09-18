import QtQuick

// A short list of named actions in a centred overlay, driven by the keyboard.
// Distinct from the search pickers: the row set is fixed, so there is nothing to
// filter and no text input to own.
//
// Rows are plain objects with a `label`, optionally `destructive` to colour them
// as a warning. `markedIndex` draws the row that is already in effect, which is
// what lets a settings menu show its current value.
Overlay {
  id: menu

  required property var actions

  property int markedIndex: -1

  signal activated(int index)

  panelWidth: Theme.menuWidth
  // Derived so adding a row cannot leave the panel the wrong height.
  panelHeight: menu.actions.length * Theme.pickerRowHeight + Theme.notificationPadding * 2

  function choose(index) {
    menu.activated(index);
  }

  ListView {
    id: list

    anchors {
      fill: parent
      margins: Theme.notificationPadding
    }

    model: menu.actions
    currentIndex: 0
    highlightMoveDuration: 0
    keyNavigationWraps: true
    focus: true

    Keys.onEscapePressed: menu.dismissed()
    Keys.onReturnPressed: menu.choose(list.currentIndex)
    Keys.onEnterPressed: menu.choose(list.currentIndex)

    // Reopening on whatever row was last highlighted would defeat any ordering
    // the caller chose to keep a destructive row off the default selection.
    onVisibleChanged: if (visible) currentIndex = 0

    delegate: Rectangle {
      required property var modelData
      required property int index

      width: list.width
      height: Theme.pickerRowHeight

      radius: Theme.roundingSmall
      color: index === list.currentIndex
        ? (modelData.destructive ? Theme.red : Theme.mauve)
        : "transparent"

      Text {
        anchors {
          left: parent.left
          right: parent.right
          leftMargin: Theme.roundingSmall
          rightMargin: Theme.roundingSmall
          verticalCenter: parent.verticalCenter
        }

        text: index === menu.markedIndex ? modelData.label + "  *" : modelData.label
        color: index === list.currentIndex
          ? Theme.base
          : (modelData.destructive ? Theme.red : Theme.text)
        font.family: Theme.fontFamily
        font.pixelSize: Theme.pickerFontSize
        elide: Text.ElideRight
      }

      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: menu.choose(index)
      }
    }
  }
}
