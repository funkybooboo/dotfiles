// Ports waybar's backlight module. The level itself is owned by SystemMetrics,
// because the OSD reads the same number and two pollers would disagree.
BarButton {
  id: root

  readonly property int percent: SystemMetrics.brightnessPercent

  text: String.fromCodePoint(root.percent < 50 ? 0xf00de : 0xf00df) + " " + root.percent + "%"
  tooltip: "Brightness: " + root.percent + "%"
}
