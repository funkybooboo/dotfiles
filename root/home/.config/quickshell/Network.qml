import Quickshell.Networking

// Ports waybar's network module: a five-step signal ramp for wifi, one glyph for
// wired, and a distinct glyph when nothing is connected.
BarButton {
  id: root

  readonly property var device: Networking.devices.values.find(d => d.connected) ?? null
  readonly property bool wifi: root.device?.type === DeviceType.Wifi
  readonly property bool wired: root.device?.type === DeviceType.Wired
  readonly property var network: root.device?.networks?.values.find(n => n.connected) ?? null

  // WifiNetwork.signalStrength is documented as 0.0 to 1.0, not a percentage.
  readonly property real strength: root.network?.signalStrength ?? 0

  readonly property var signalRamp: [0xf092f, 0xf091f, 0xf0922, 0xf0925, 0xf0928]
  readonly property int rampIndex: Math.min(4, Math.max(0, Math.floor(root.strength * 5)))

  text: {
    if (root.wired)
      return String.fromCodePoint(0xf0002);
    if (root.wifi)
      return String.fromCodePoint(root.signalRamp[root.rampIndex]);
    return String.fromCodePoint(0xf092e);
  }

  // Disconnected is the only network state worth colouring. A connected link is
  // the normal case and colouring it green would put a permanent accent in the bar
  // for information the glyph already carries.
  textColor: root.device === null ? Theme.red : Theme.text

  // Arrows are codepoints so the file stays ASCII, as with the Nerd Font glyphs.
  readonly property string throughput: String.fromCodePoint(0x2193) + " " + SystemMetrics.downBits
    + "  " + String.fromCodePoint(0x2191) + " " + SystemMetrics.upBits

  tooltip: {
    const action = "Click: open Wi-Fi manager";
    if (root.wired)
      return "Connected<br>" + root.throughput + "<br>" + action;
    if (root.wifi)
      return "Wi-Fi: " + (root.network?.name ?? "unknown")
        + " (" + Math.round(root.strength * 100) + "%)<br>"
        + root.throughput + "<br>" + action;
    return "Disconnected<br>" + action;
  }
}
