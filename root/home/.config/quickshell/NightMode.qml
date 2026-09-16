// Ports waybar's custom/nightmode module, which read its state from the
// nightmode-indicator script polling for hyprsunset. Moon when the filter is on,
// sun when it is off.
BarButton {
  id: root

  readonly property bool on: probe.active

  text: String.fromCodePoint(root.on ? 0xf186 : 0xf185)
  tooltip: "Night mode: " + (root.on ? "On" : "Off") + "<br>"
    + "Click to toggle  (Super+Ctrl+N)"

  PidProbe {
    id: probe

    processName: "hyprsunset"
  }
}
