import Quickshell.Io
import QtQuick

// Polls whether a named process is alive. Three bar modules need this because
// the tools they front -- hyprsunset, wf-recorder, hypridle -- publish no status
// channel, only their own existence. waybar needed a separate polling shell
// script per module for the same reason; this is the one place that logic lives.
QtObject {
  id: root

  property string processName
  property int intervalMs: 2000

  // Written by the probe, read by the module.
  property bool active: false

  property Process probe: Process {
    command: ["pgrep", "-x", root.processName]
    onExited: exitCode => root.active = exitCode === 0
  }

  property Timer timer: Timer {
    interval: root.intervalMs
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.probe.running = true
  }
}
