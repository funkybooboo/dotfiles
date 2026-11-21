pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick

// The applet drawer: a chevron that reveals the tray items.
//
// Opening takes intent. The pointer must DWELL on the row for DwellMs before
// the drawer opens, so sweeping along the bar toward the buttons to the right
// never pops it open (and never shoves those buttons leftward mid-sweep).
// Leaving mid-dwell cancels before any motion starts.
//
// A right-click menu PINS the drawer open. QsMenuAnchor owns the menu -- the
// same QtWidgets menu display() used to show, so submenus and checkboxes keep
// behaving the way each app intends -- and its visible property holds the
// drawer while the pointer travels down into the menu. When the menu closes,
// the drawer keeps only what hover alone justifies. The anchor is closed
// before a menu swap: assigning a new menu mid-open would leave it latched
// shut (mOpen never clears), and open() then refuses.
//
// Motion: a 200ms OutCubic width reveal, both directions, and nothing else --
// no chevron rotation, no fade; the original waybar expander dimmed the
// chevron while collapsed and that is the whole state language. (A rotation
// flourish was tried 2026-11-21 and read as "too flashy".) The old 600ms
// InOutCubic read as sluggish: InOut easing puts dead time at both ends, and
// the whole right button row shifts while the drawer animates, so every
// extra millisecond was visible. Closing runs on a short grace instead of
// instantly: a pointer that dips out and returns within GraceMs never starts
// a shrink at all.

Row {
  id: root

  // The chevron stays visible even with zero tray items: it is the affordance
  // that the tray exists, and hiding it (tried 2026-11-21) makes an empty tray
  // -- items gone because a quickshell restart drops every StatusNotifierItem
  // registration until each app re-registers -- read as "the drawer vanished".

  // The drawer's own margins. The chevron BarButton carries ~9px of internal
  // blank either side of its glyph (the shared waybar module rule), so LeadGap
  // on top of that lands the chevron-to-first-icon gap at ~17px, matching the
  // inter-icon spacing; TrailGap plus the bell button's internal 7.5px does
  // the same on the right, where the drawer edge otherwise lands flush on
  // the last icon.
  readonly property int leadGap: 8
  readonly property int trailGap: 10

  // No spacing: the drawer owns its own leading gap, so a collapsed drawer
  // really is zero width. Row spacing around a zero-width child would leave a
  // visible hole and make that gap pop in as the drawer opens.
  spacing: 0

  // The drawer's authoritative state. Hover alone never opens it -- dwell
  // must fire first -- and a menu (or the close grace) can hold it past a
  // hover exit, which a plain binding on hover.hovered could not express.
  property bool open: false

  HoverHandler {
    id: hover

    onHoveredChanged: {
      if (hovered) {
        closeGrace.stop()
        dwell.restart()
      } else if (!menuAnchor.visible) {
        dwell.stop()
        closeGrace.restart()
      }
      // Exiting while a menu is open changes nothing: the menu is the thing
      // the user is interacting with now, and it holds the drawer by itself.
    }
  }

  // The hover-intent gate: short enough that a deliberate hover opens almost
  // immediately, long enough that a sweep across the chevron never triggers.
  Timer {
    id: dwell

    interval: 120
    onTriggered: root.open = true
  }

  // A pointer that leaves and returns inside the grace never sees the drawer
  // move; a pointer that is really gone starts the 200ms shrink here.
  Timer {
    id: closeGrace

    interval: 100
    onTriggered: root.open = false
  }

  QsMenuAnchor {
    id: menuAnchor

    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom

    // A menu that ends while the pointer is back on the drawer has already
    // earned its keep: hovering there is intent, dwell or no dwell.
    onClosed: root.open = hover.hovered
  }

  BarButton {
    anchors.verticalCenter: parent.verticalCenter
    text: String.fromCodePoint(0xf053)
    tooltip: "System tray"
    opacity: root.open ? 1.0 : Theme.dimmedOpacity
  }

  // Clipping is what turns a width animation into a reveal: the icons wait in
  // place while the clip edge slides across them.
  Item {
    id: drawer

    anchors.verticalCenter: parent.verticalCenter

    implicitHeight: Theme.barHeight
    implicitWidth: content.implicitWidth + root.leadGap + root.trailGap
    width: root.open ? drawer.implicitWidth : 0
    clip: true

    Behavior on width {
      NumberAnimation {
        duration: 200
        easing.type: Easing.OutCubic
      }
    }

    Row {
      id: content

      anchors {
        verticalCenter: parent.verticalCenter
        left: parent.left
        leftMargin: root.leadGap
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
            if (item.modelData.onlyMenu || (mouse.button === Qt.RightButton && item.modelData.hasMenu)) {
              // Close before the swap: open() refuses while visible, and a
              // mid-open menu reassignment would latch the anchor shut.
              // The anchor snapshots its geometry at open(), so the menu and
              // anchor item are both set first.
              if (menuAnchor.visible)
                menuAnchor.close()
              menuAnchor.menu = item.modelData.menu
              menuAnchor.anchor.item = item
              menuAnchor.open()
            } else if (mouse.button === Qt.MiddleButton) {
              item.modelData.secondaryActivate()
            } else if (mouse.button === Qt.LeftButton) {
              item.modelData.activate()
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
