import Quickshell
import Quickshell.Io
import QtQuick

// Ports waybar's network module: a five-step signal ramp for wifi, one glyph
// for wired, and a distinct glyph when nothing is connected.
//
// State comes from the wifi-status helper, NOT Quickshell.Networking: the
// singleton's only backend is NetworkManager (quickshell.network.networkmanager
// in the binary -- no iwd support), while this fleet runs iwd + systemd-
// networkd (migrations/000402) with no NetworkManager to talk to. Against the
// real backend, Networking.devices is always empty here and the module read
// "Disconnected" on a machine that was online.
BarButton {
  id: root

  // wifi-status prints: "wifi <dbm> <ssid>" | "wired" | "off"
  property string kind: "off"
  property string ssid: ""
  property real dbm: -32768

  readonly property bool wired: root.kind === "wired"
  readonly property bool wifi: root.kind === "wifi"

  // dBm onto the ramp the way the NetworkManager module did: -30 dBm and up is
  // full strength, -100 dBm and down is gone. Sentinels clamp to 0.
  readonly property real strength: Math.max(0, Math.min(1, (root.dbm + 100) / 70))

  readonly property var signalRamp: [0xf092f, 0xf091f, 0xf0922, 0xf0925, 0xf0928]
  readonly property int rampIndex: Math.min(4, Math.max(0, Math.floor(root.strength * 5)))

  text: {
    if (root.wired)
      return String.fromCodePoint(0xf0002);
    if (root.wifi)
      return String.fromCodePoint(root.signalRamp[root.rampIndex]);
    return String.fromCodePoint(0xf092e);
  }

  // Arrows are codepoints so the file stays ASCII, as with the Nerd Font glyphs.
  readonly property string throughput: String.fromCodePoint(0x2193) + " " + SystemMetrics.downBits
    + "  " + String.fromCodePoint(0x2191) + " " + SystemMetrics.upBits

  tooltip: {
    const action = "Click: open Wi-Fi manager  (Super+Shift+W)";
    if (root.wired)
      return "Connected<br>" + root.throughput + "<br>" + action;
    if (root.wifi)
      return "Wi-Fi: " + root.ssid
        + " (" + Math.round(root.strength * 100) + "%)<br>"
        + root.throughput + "<br>" + action;
    return "Disconnected<br>" + action;
  }

  property Process statusProcess: Process {
    command: [Quickshell.env("HOME") + "/.local/bin/wifi-status"]

    stdout: StdioCollector {
      id: statusOutput

      onStreamFinished: {
        const fields = statusOutput.text.trim().split(/\s+/);
        if (fields[0] === "wired") {
          root.kind = "wired";
          return;
        }
        if (fields[0] === "wifi") {
          const dbm = Number(fields[1]);
          root.kind = "wifi";
          root.dbm = isFinite(dbm) ? dbm : -32768;
          root.ssid = fields.length > 2 ? fields.slice(2).join(" ") : "<unknown>";
          return;
        }
        root.kind = "off";
      }
    }
  }

  property Timer statusTimer: Timer {
    interval: 5000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: statusProcess.running = true
  }
}