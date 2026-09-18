pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// Pulls a one-time code out of an incoming notification and puts it on the
// clipboard, because the codes arrive as browser push (webmail) where the only way
// to use one is to read it off the screen and retype it.
//
// Keyword-gated, never a bare digit match. An email preview is full of order
// numbers, tracking numbers, prices and dates, so `\d{6}` alone would fire
// constantly; a digit run only counts when a code-ish word sits near it.
Singleton {
  id: root

  // Deliberately not anchored to a sender: the notification comes from the browser,
  // so appName is "Firefox" and carries no signal about content.
  readonly property var keyword: /\b(?:code|otp|2fa|passcode|pin|verification|verify|one[- ]?time)\b/i
  readonly property var digits: /\b\d{4,8}\b/g

  // How far from the keyword a digit run may sit and still be considered its code.
  // Wide enough for "Your verification code is 123456", tight enough that a code
  // word early in a subject does not adopt a tracking number late in the body.
  readonly property int proximity: 40

  readonly property string appName: "Shell"

  property string lastCode: ""

  // The confirmation this emits contains the code, so it matches its own pattern.
  // Without this guard it would extract from itself forever.
  function scan(notification) {
    if (notification.appName === root.appName)
      return;

    const code = root.find(notification.summary + "  " + notification.body);
    if (code === "")
      return;

    root.lastCode = code;
    copier.command = ["wl-copy", "--", code];
    copier.running = true;
  }

  // Returns the digit run belonging to the keyword, or "" when nothing qualifies.
  //
  // A run AFTER the keyword wins over a nearer one before it, because that is where
  // codes sit -- "your code is 123456". Plain nearest-wins picked the wrong number
  // out of "Ref 777777 aside, the verification code is 135790". The before-case is
  // kept as a fallback for the other common phrasing, "728391 is your code".
  function find(text) {
    const marker = text.match(root.keyword);
    if (!marker)
      return "";

    const at = marker.index;
    let after = "";
    let afterDistance = Infinity;
    let before = "";
    let beforeDistance = Infinity;

    // exec() with a /g regex walks matches, and lastIndex must be reset because the
    // object is shared across calls.
    root.digits.lastIndex = 0;

    let hit;
    while ((hit = root.digits.exec(text)) !== null) {
      const distance = Math.abs(hit.index - at);
      if (distance > root.proximity)
        continue;

      if (hit.index >= at) {
        if (distance < afterDistance) {
          after = hit[0];
          afterDistance = distance;
        }
      } else if (distance < beforeDistance) {
        before = hit[0];
        beforeDistance = distance;
      }
    }

    return after !== "" ? after : before;
  }

  Process {
    id: copier

    onExited: {
      notifier.command = [
        "notify-send", "--app-name", root.appName,
        "Code copied", root.lastCode
      ];
      notifier.running = true;

      // cliphist stores asynchronously via `wl-paste --watch`, so the entry does not
      // exist yet. Purging leaves the code on the clipboard and pasteable while
      // keeping it out of the on-disk history, which is otherwise permanent.
      purgeDelay.restart();
    }
  }

  Process {
    id: notifier
  }

  Timer {
    id: purgeDelay

    interval: 400
    repeat: true
    triggeredOnStart: false

    property int attempts: 0

    onRunningChanged: if (running) attempts = 0

    onTriggered: {
      attempts++;
      purge.command = ["cliphist", "delete-query", root.lastCode];
      purge.running = true;

      // A couple of attempts covers the write landing late; more would mean
      // something else is wrong and retrying forever would hide it.
      if (attempts >= 3)
        purgeDelay.stop();
    }
  }

  Process {
    id: purge
  }
}
