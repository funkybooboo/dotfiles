import Quickshell.Bluetooth

// Ports waybar's bluetooth module. It names the connected device the way waybar's
// format-connected did, and hides itself entirely when there is no controller,
// matching waybar's empty format-no-controller.
BarButton {
  id: root

  readonly property var adapter: Bluetooth.defaultAdapter
  readonly property var connected: Bluetooth.devices.values.filter(d => d.connected)

  visible: root.adapter !== null

  text: {
    if (!root.adapter?.enabled)
      return String.fromCodePoint(0xf00b2);
    if (root.connected.length > 0) {
      const device = root.connected[0];
      return String.fromCodePoint(0xf00b1) + " " + (device.deviceName || device.name);
    }
    return String.fromCodePoint(0xf00af);
  }

  tooltip: "Bluetooth: " + root.connected.length + " connected<br>"
    + "Click: open Bluetooth manager"
}
