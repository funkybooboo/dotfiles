pragma Singleton
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

// Volume and brightness control for the media keys. Deliberately silent: there is
// no on-screen display, because the bar's audio and backlight modules are the
// readout. swayosd was tried in this setup before and removed.
//
// Volume is written straight to the Pipewire node rather than shelling out to
// wpctl, so the bar reads back the value that was actually set. Brightness has no
// API and still needs brightnessctl.
Singleton {
  id: root

  // media-keys allowed boost to 150% and defaulted to 5% steps; both are kept so
  // the keys behave exactly as before.
  readonly property real volumeMax: 1.5
  readonly property int defaultStep: 5

  readonly property var sink: Pipewire.defaultAudioSink
  readonly property var source: Pipewire.defaultAudioSource

  readonly property real volume: root.sink?.audio?.volume ?? 0
  readonly property bool muted: root.sink?.audio?.muted ?? false
  readonly property bool micMuted: root.source?.audio?.muted ?? false

  // Pipewire nodes only publish property changes while something tracks them.
  PwObjectTracker {
    objects: [root.sink, root.source].filter(node => node)
  }

  function stepVolume(percent) {
    if (!root.sink?.audio)
      return;

    const next = root.sink.audio.volume + percent / 100;
    root.sink.audio.volume = Math.max(0, Math.min(root.volumeMax, next));
  }

  function toggleMute() {
    if (root.sink?.audio)
      root.sink.audio.muted = !root.sink.audio.muted;
  }

  function toggleMicMute() {
    if (root.source?.audio)
      root.source.audio.muted = !root.source.audio.muted;
  }

  property Process brightnessProcess: Process {
    // brightnessctl clamps to the device range, so a large step lands on the rail
    // rather than erroring -- which is what the SHIFT bindings rely on.
    onExited: SystemMetrics.refreshBrightness()
  }

  function stepBrightness(percent) {
    const change = percent >= 0 ? "+" + percent + "%" : Math.abs(percent) + "%-";
    root.brightnessProcess.command = ["brightnessctl", "set", change];
    root.brightnessProcess.running = true;
  }
}
