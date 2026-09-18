import QtQuick

// Ports waybar's custom/recording module, which polled the recording-indicator
// script for a running wf-recorder. Idle draws nothing at all, matching waybar's
// empty text and min-width 0.
BarButton {
  id: root

  readonly property bool recording: probe.active

  text: String.fromCodePoint(0x23fa)
  textColor: Theme.red
  tooltip: "Screen recording toggle  (Super+Shift+R)"

  // Hidden rather than blank so the Row skips it entirely: an idle module still
  // claiming min-width would push the centre clock off centre.
  visible: root.recording

  PidProbe {
    id: probe

    processName: "wf-recorder"
  }
}
