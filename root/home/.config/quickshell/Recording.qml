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

  // waybar blinked the glyph by animating its colour to the bar background once
  // a second; fading it reads the same and does not need a colour animation.
  SequentialAnimation on opacity {
    running: root.recording
    loops: Animation.Infinite

    NumberAnimation {
      from: 1.0
      to: 0.0
      duration: 500
    }

    NumberAnimation {
      from: 0.0
      to: 1.0
      duration: 500
    }
  }
}
