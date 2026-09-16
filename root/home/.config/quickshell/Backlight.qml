import Quickshell.Io
import QtQuick

// Ports waybar's backlight module. quickshell has no brightness API, so the level
// comes from brightnessctl. It is polled rather than event-driven, which is the
// one place this reacts slower than waybar's udev watch; stage 5 moves brightness
// changes into the shell's own OSD, which can update this directly.
BarButton {
  id: root

  property int percent: 0

  text: String.fromCodePoint(root.percent < 50 ? 0xf00de : 0xf00df) + " " + root.percent + "%"
  tooltip: "Brightness: " + root.percent + "%"

  Process {
    id: probe

    command: ["brightnessctl", "-m"]

    stdout: StdioCollector {
      id: output

      // brightnessctl -m prints one CSV line per device:
      // name,class,current,percent%,max
      onStreamFinished: {
        const field = output.text.trim().split("\n")[0]?.split(",")[3];
        if (field)
          root.percent = parseInt(field, 10);
      }
    }
  }

  Timer {
    interval: 2000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: probe.running = true
  }
}
