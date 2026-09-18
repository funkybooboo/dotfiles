import Quickshell.Services.UPower

// Ports waybar's battery module. waybar's format-icons were ten glyphs running
// empty to full, so the ramps are indexed by decile to reproduce the same steps,
// and the warning/critical thresholds match its `states` block.
BarButton {
  id: root

  readonly property var device: UPower.displayDevice
  // UPowerDevice.percentage is a 0..1 fraction, not a percent.
  readonly property int percent: Math.round((root.device?.percentage ?? 0) * 100)
  readonly property bool charging: root.device?.state === UPowerDeviceState.Charging
  readonly property bool full: root.device?.state === UPowerDeviceState.FullyCharged
  readonly property bool discharging: root.device?.state === UPowerDeviceState.Discharging

  readonly property var dischargeRamp: [0xf007a, 0xf007b, 0xf007c, 0xf007d, 0xf007e,
                                        0xf007f, 0xf0080, 0xf0081, 0xf0082, 0xf0079]
  readonly property var chargeRamp: [0xf089c, 0xf0086, 0xf0087, 0xf0088, 0xf089d,
                                     0xf0089, 0xf089e, 0xf008a, 0xf008b, 0xf0085]

  readonly property int rampIndex: Math.min(9, Math.max(0, Math.floor(root.percent / 10)))

  text: {
    if (root.full)
      return String.fromCodePoint(0xf0079) + " " + root.percent + "%";
    const ramp = root.charging ? root.chargeRamp : root.dischargeRamp;
    return String.fromCodePoint(ramp[root.rampIndex]) + " " + root.percent + "%";
  }

  // waybar prefixed the charging and discharging tooltips with draw in watts and
  // left the idle/full one as capacity alone.
  tooltip: {
    const action = "Click: power mode menu";
    const watts = Math.round(root.device?.changeRate ?? 0);
    if (root.charging || root.discharging)
      return watts + "W " + root.percent + "%<br>" + action;
    return root.percent + "%<br>" + action;
  }

  textColor: {
    if (root.charging || root.full)
      return Theme.text;
    if (root.percent <= 10)
      return Theme.red;
    if (root.percent <= 20)
      return Theme.peach;
    return Theme.text;
  }
}
