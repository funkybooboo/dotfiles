import Quickshell
import Quickshell.Wayland
import QtQuick

// Replaces hyprpaper, and with it set-wallpaper.sh, monitor-watcher.sh and the
// hypr-wallpaper.service that kept them running. Those existed to notice monitor
// changes: the script polled `hyprctl monitors`, wrote a hyprpaper.conf per
// output and restarted hyprpaper, while a socat loop on the Hyprland event socket
// re-ran it on monitoradded/monitorremoved. One surface per screen, created by
// Variants, is that whole mechanism.
PanelWindow {
  id: background

  property var modelData
  screen: modelData

  anchors {
    top: true
    bottom: true
    left: true
    right: true
  }

  // Covers the output but claims none of it, and takes no input: a fullscreen
  // surface that accepted clicks would swallow every click on the desktop.
  //
  // Ignoring exclusion is what makes it the full output rather than the space the
  // bar leaves over -- respecting the bar's zone would crop the wallpaper by the
  // bar's height, which only looks harmless while the bar is opaque.
  // No exclusiveZone here on purpose: Ignore mode does not permit one, and
  // setting both puts the window back to respecting the bar.
  exclusionMode: ExclusionMode.Ignore
  mask: Region {}

  WlrLayershell.layer: WlrLayer.Background

  // Shows through only while the image loads, or if the file is missing.
  color: Theme.base

  Image {
    anchors.fill: parent

    source: Theme.wallpaper
    fillMode: Image.PreserveAspectCrop
    asynchronous: true

    // Decode at the output's size rather than the file's: the same wallpaper is
    // drawn on four monitors, and full-resolution decodes would be paid per
    // surface.
    sourceSize.width: background.width
    sourceSize.height: background.height
  }
}
