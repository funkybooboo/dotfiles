import Quickshell.Services.Pipewire

// Ports waybar's pulseaudio module. Mute is toggled on the Pipewire node itself
// rather than by shelling out to a mixer CLI the way waybar's on-click-right did,
// so the click and the readout cannot disagree.
BarButton {
  id: root

  readonly property var sink: Pipewire.defaultAudioSink
  readonly property int percent: Math.round((root.sink?.audio?.volume ?? 0) * 100)
  readonly property bool muted: root.sink?.audio?.muted ?? false

  // Pipewire nodes only publish property changes while something tracks them.
  PwObjectTracker {
    objects: root.sink ? [root.sink] : []
  }

  // waybar mapped headphone, headset, hands-free and phone sinks to one glyph and
  // used the volume ramp only for speakers. Bluetooth sinks carry no
  // device.form-factor on the node, so they are recognised by node.name.
  readonly property bool headphones: {
    const props = root.sink?.properties ?? ({});
    if ((props["node.name"] ?? "").startsWith("bluez_output"))
      return true;
    return ["headset", "headphone", "hands-free", "phone"].includes(props["device.form-factor"] ?? "");
  }

  // waybar's default ramp was three glyphs; index by third of the volume range.
  readonly property int ramp: root.percent < 34
    ? 0xf026
    : (root.percent < 67 ? 0xf027 : 0xf028)

  readonly property int glyph: root.headphones ? 0xf025 : root.ramp

  text: String.fromCodePoint(root.muted ? 0xf075f : root.glyph) + " " + root.percent + "%"
  tooltip: "Volume " + root.percent + "%<br>"
    + "Click: open volume mixer  |  Right-click: mute"

  onRightClicked: {
    if (root.sink?.audio)
      root.sink.audio.muted = !root.sink.audio.muted;
  }
}
