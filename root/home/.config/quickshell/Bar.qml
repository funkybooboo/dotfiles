import Quickshell
import QtQuick

// Replaces waybar. Section order, glyphs, click targets and geometry are ported
// from the waybar config and style.css this removes, so the bar reads the same.
// Icons are given as Nerd Font codepoints rather than literal characters: the
// file stays ASCII, and a codepoint is greppable where a private-use glyph is
// not.
PanelWindow {
  id: bar

  property var modelData
  screen: modelData

  anchors {
    top: true
    left: true
    right: true
  }

  implicitHeight: Theme.barHeight
  color: Theme.base

  // Shell scripts still own the actions behind these buttons. Later stages
  // replace the ones that become native panels (launcher, clipboard, switcher).
  readonly property string bin: Quickshell.env("HOME") + "/.local/bin/"

  // hypr-float-launch floats and centres whatever window the command opens; it
  // is how every one of these actions currently reaches the screen.
  function floating(argv) {
    Quickshell.execDetached([bar.bin + "hypr-float-launch"].concat(argv));
  }

  function floatingTerm(argv) {
    bar.floating(["ghostty", "-e"].concat(argv));
  }

  Row {
    anchors {
      left: parent.left
      leftMargin: Theme.barEdgeMargin
      verticalCenter: parent.verticalCenter
    }

    BarButton {
      text: String.fromCodePoint(0xf00a)
      tooltip: "Applications  (Super+Space)"
      onClicked: LauncherState.toggle()
    }

    BarButton {
      text: String.fromCodePoint(0xf0349)
      tooltip: "Search windows  (Super+Slash)"
      onClicked: bar.floatingTerm([bar.bin + "hypr-window-switcher-inner"])
    }

    Workspaces {
      anchors.verticalCenter: parent.verticalCenter
    }
  }

  Row {
    anchors.centerIn: parent

    Clock {
      onClicked: bar.floatingTerm([bar.bin + "calendar-tui"])
    }

    Recording {
      anchors.verticalCenter: parent.verticalCenter
      onClicked: Quickshell.execDetached([bar.bin + "screencast"])
    }
  }

  Row {
    anchors {
      right: parent.right
      rightMargin: Theme.barEdgeMargin
      verticalCenter: parent.verticalCenter
    }

    Tray {
      anchors.verticalCenter: parent.verticalCenter
    }

    BarButton {
      text: String.fromCodePoint(0xf059)
      tooltip: "Keybindings  (Super+C)"
      onClicked: bar.floatingTerm([bar.bin + "hypr-keybinds"])
    }

    BarButton {
      text: String.fromCodePoint(0xf0147)
      tooltip: "Clipboard history  (Super+Ctrl+V)"
      onClicked: ClipboardState.toggle()
    }

    Audio {
      onClicked: bar.floatingTerm(["wiremix"])
    }

    Bluetooth {
      onClicked: bar.floatingTerm(["bluetui"])
    }

    Network {
      onClicked: bar.floatingTerm(["nmtui"])
    }

    BarButton {
      text: String.fromCodePoint(0xf2db)
      tooltip: "CPU: " + SystemMetrics.cpuPercent + "%<br>"
        + "Click: open system monitor  (Super+Shift+T)"
      onClicked: bar.floatingTerm(["btop"])
    }

    BarButton {
      text: String.fromCodePoint(0xefc5)
      tooltip: "RAM: " + SystemMetrics.memoryPercent + "%<br>"
        + "Click: open system monitor  (Super+Shift+T)"
      onClicked: bar.floatingTerm(["btop"])
    }

    BarButton {
      text: String.fromCodePoint(0xf02ca)
      tooltip: "Disk: " + SystemMetrics.diskPath + " " + SystemMetrics.diskPercent + "%<br>"
        + "Click: open disk usage  (Super+Shift+D)"
      onClicked: bar.floatingTerm(["ncdu", "/"])
    }

    BarButton {
      text: String.fromCodePoint(0xf0379)
      tooltip: "Display settings  (Super+D)"
      onClicked: bar.floating(["nwg-displays"])
    }

    Backlight {}

    NightMode {
      onClicked: Quickshell.execDetached([bar.bin + "nightmode-toggle"])
    }

    KeepAwake {
      onClicked: Quickshell.execDetached([bar.bin + "keepawake-toggle"])
    }

    Battery {
      onClicked: bar.floating([bar.bin + "power-mode-menu"])
    }

    BarButton {
      text: String.fromCodePoint(0x23fb)
      tooltip: "Power menu  (lock / logout / restart / shutdown)"
      onClicked: Quickshell.execDetached([bar.bin + "power-menu"])
    }
  }
}
