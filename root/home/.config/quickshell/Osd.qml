pragma Singleton
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import QtQuick

// Volume and brightness control, plus the popup state that shows the result.
// This is new: media-keys applied changes silently and the bar was the only
// readout, so there was never an on-screen display.
//
// Volume is written straight to the Pipewire node instead of shelling out to
// wpctl, so the value the OSD draws is the value that was set. Brightness has no
// API and still needs brightnessctl.
Singleton {
  id: root

  // media-keys allowed boost to 150% and defaulted to 5% steps; both are kept so
  // the keys behave exactly as before.
  readonly property real volumeMax: 1.5
  readonly property int defaultStep: 5

  // "volume", "brightness", or "" when nothing is showing.
  property string kind: ""

  readonly property var sink: Pipewire.defaultAudioSink
  readonly property var source: Pipewire.defaultAudioSource

  readonly property real volume: root.sink?.audio?.volume ?? 0
  readonly property bool muted: root.sink?.audio?.muted ?? false
  readonly property bool micMuted: root.source?.audio?.muted ?? false

  // Pipewire nodes only publish property changes while something tracks them.
  PwObjectTracker {
    objects: [root.sink, root.source].filter(node => node)
  }

  property Timer hideTimer: Timer {
    interval: Theme.osdTimeout
    onTriggered: root.kind = ""
  }

  function flash(kind) {
    root.kind = kind;
    root.hideTimer.restart();
  }

  function stepVolume(percent) {
    if (!root.sink?.audio)
      return;

    const next = root.sink.audio.volume + percent / 100;
    root.sink.audio.volume = Math.max(0, Math.min(root.volumeMax, next));
    root.flash("volume");
  }

  function toggleMute() {
    if (!root.sink?.audio)
      return;

    root.sink.audio.muted = !root.sink.audio.muted;
    root.flash("volume");
  }

  function toggleMicMute() {
    if (!root.source?.audio)
      return;

    root.source.audio.muted = !root.source.audio.muted;
    root.flash("volume");
  }

  property Process brightnessProcess: Process {
    // brightnessctl clamps to the device range, so a large step lands on the rail
    // rather than erroring -- which is what the old SHIFT bindings relied on.
    onExited: SystemMetrics.refreshBrightness()
  }

  function stepBrightness(percent) {
    const change = percent >= 0 ? "+" + percent + "%" : Math.abs(percent) + "%-";
    root.brightnessProcess.command = ["brightnessctl", "set", change];
    root.brightnessProcess.running = true;
    root.flash("brightness");
  }
}
