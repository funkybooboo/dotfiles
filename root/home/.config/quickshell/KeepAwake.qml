// Ports waybar's custom/keepawake module. It shows a bed while the idle daemon
// is running and a coffee cup while it is suppressed, because the current
// keep-awake toggle works by killing hypridle outright. Stage 8 replaces both the
// probe and the toggle with an IdleInhibitor, at which point "awake" stops being
// the absence of a process.
BarButton {
  id: root

  readonly property bool idleRunning: probe.active

  text: String.fromCodePoint(root.idleRunning ? 0xf236 : 0xf0f4)
  tooltip: (root.idleRunning ? "Idle: normal" : "Staying awake") + "<br>"
    + "Click to toggle  (Super+Ctrl+I)"

  PidProbe {
    id: probe

    processName: "hypridle"
  }
}
