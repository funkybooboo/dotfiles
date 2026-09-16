pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// Live CPU, memory and disk figures for the bar tooltips. waybar read these
// itself; quickshell has no API for any of them, so they come from /proc and df
// here. Intervals match waybar's: 2s for cpu and memory, 30s for disk.
Singleton {
  id: root

  property int cpuPercent: 0
  property int memoryPercent: 0
  property int diskPercent: 0

  readonly property string diskPath: "/"

  // Formatted the way waybar's {bandwidthDownBits}/{bandwidthUpBits} read.
  property string downBits: "0b/s"
  property string upBits: "0b/s"

  property real previousRx: 0
  property real previousTx: 0
  property real previousNetAt: 0

  // CPU load is a delta between two /proc/stat samples, so the first sample only
  // establishes a baseline and reports nothing.
  property real previousTotal: 0
  property real previousIdle: 0

  function readCpu(text) {
    const line = text.split("\n").find(l => l.startsWith("cpu "));
    if (!line)
      return;

    const fields = line.trim().split(/\s+/).slice(1).map(Number);
    const idle = fields[3] + (fields[4] ?? 0);
    const total = fields.reduce((sum, value) => sum + value, 0);

    const deltaTotal = total - root.previousTotal;
    const deltaIdle = idle - root.previousIdle;
    root.previousTotal = total;
    root.previousIdle = idle;

    if (deltaTotal > 0)
      root.cpuPercent = Math.round(100 * (1 - deltaIdle / deltaTotal));
  }

  function readMemory(text) {
    const field = key => {
      const match = text.match(new RegExp("^" + key + ":\\s+(\\d+)", "m"));
      return match ? Number(match[1]) : 0;
    };

    const total = field("MemTotal");
    const available = field("MemAvailable");

    if (total > 0)
      root.memoryPercent = Math.round(100 * (total - available) / total);
  }

  // df -P guarantees one line per filesystem, so the figure is always field 5 of
  // line 2 regardless of how long the device name is.
  function readDisk(text) {
    const line = text.trim().split("\n")[1];
    if (!line)
      return;

    const percent = line.trim().split(/\s+/)[4];
    if (percent)
      root.diskPercent = parseInt(percent, 10);
  }

  function formatBits(bitsPerSecond) {
    const units = ["b/s", "kb/s", "Mb/s", "Gb/s"];
    let value = bitsPerSecond;
    let unit = 0;
    while (value >= 1000 && unit < units.length - 1) {
      value /= 1000;
      unit++;
    }
    return (unit === 0 ? Math.round(value) : value.toFixed(1)) + units[unit];
  }

  // Counters in /proc/net/dev are cumulative, so a rate needs two samples and the
  // real elapsed time between them -- the timer interval is a request, not a
  // guarantee, and using it as the divisor overstates the rate whenever the shell
  // is busy. lo is excluded: loopback traffic is not network throughput.
  function readNetwork(text) {
    let rx = 0;
    let tx = 0;

    for (const line of text.split("\n")) {
      const parts = line.split(":");
      if (parts.length < 2)
        continue;

      const name = parts[0].trim();
      if (name === "lo" || name === "Inter-| Receive" || name === "")
        continue;

      const fields = parts[1].trim().split(/\s+/).map(Number);
      if (fields.length < 9)
        continue;

      rx += fields[0];
      tx += fields[8];
    }

    const now = Date.now();
    const elapsed = (now - root.previousNetAt) / 1000;

    if (root.previousNetAt > 0 && elapsed > 0) {
      root.downBits = root.formatBits(Math.max(0, rx - root.previousRx) * 8 / elapsed);
      root.upBits = root.formatBits(Math.max(0, tx - root.previousTx) * 8 / elapsed);
    }

    root.previousRx = rx;
    root.previousTx = tx;
    root.previousNetAt = now;
  }

  property FileView netFile: FileView {
    id: netFile

    path: "/proc/net/dev"
    onLoaded: root.readNetwork(netFile.text())
  }

  property FileView statFile: FileView {
    id: statFile

    path: "/proc/stat"
    onLoaded: root.readCpu(statFile.text())
  }

  property FileView memoryFile: FileView {
    id: memoryFile

    path: "/proc/meminfo"
    onLoaded: root.readMemory(memoryFile.text())
  }

  property Process diskProcess: Process {
    command: ["df", "-P", root.diskPath]

    stdout: StdioCollector {
      id: diskOutput

      onStreamFinished: root.readDisk(diskOutput.text)
    }
  }

  property Timer procTimer: Timer {
    interval: 2000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      statFile.reload();
      memoryFile.reload();
      netFile.reload();
    }
  }

  property Timer diskTimer: Timer {
    interval: 30000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.diskProcess.running = true
  }
}
