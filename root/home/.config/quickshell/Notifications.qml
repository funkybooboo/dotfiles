pragma Singleton
import Quickshell
import Quickshell.Services.Notifications

// Replaces mako as the notification daemon. Geometry, colours and timeouts are
// ported from mako/config; the popups live in NotificationLayer, the review
// surface in NotificationPanel.
//
// Toasts and the panel are two views of one list: every tracked notification is
// in the panel's history by default, so closing a toast already "saves it for
// later". close() only hides one from the toast stack; remove() is the only path
// that deletes. There is no cross-restart persistence -- quickshell 0.3.1 has
// none built in (persistenceSupported only advertises the spec capability and
// keepOnReload covers config reloads), so logout, reboot or a crash clears the
// history. That is the deliberate v1 scope.
Singleton {
  id: root

  // mako's `set-mode dnd` kept receiving notifications and only stopped showing
  // them, so this suppresses the popup rather than the tracking: silent mode
  // saves everything for the panel to review.
  property bool doNotDisturb: false

  readonly property var list: server.trackedNotifications

  // Closed notifications are kept tracked and merely hidden -- calling dismiss()
  // untracks and destroys the object, leaving nothing to restore or list but a
  // copy. The cost is that the sender does not learn a notification was closed
  // until it is evicted or removed, which is why the retained set is bounded.
  property var closedIds: []

  // Quickshell's Notification carries no arrival time, so the panel's "5m ago"
  // labels come from this map. Mutated in place -- the panel's age labels
  // re-read it on every 30s tick and on open, and QML's object-spread syntax
  // would be the only reason to copy-per-write, so there is none.
  property var received: ({})

  // One cap for the whole tracked set. The old code bounded only the closed
  // bookkeeping, so a burst of resident or critical notifications -- which never
  // auto-expire -- grew without a limit.
  readonly property int retainedLimit: 50

  readonly property var visible: root.list.values.filter(n => !root.closedIds.includes(n.id))

  // The panel's model, newest first.
  readonly property var history: root.list.values.slice().reverse()

  function close(notification) {
    root.closedIds = [...root.closedIds, notification.id];
    root.enforceRetained();
  }

  function closeAll() {
    for (const notification of root.visible)
      root.close(notification);
  }

  // The delete path: gone from the toasts AND the panel.
  function remove(notification) {
    if (!notification)
      return;

    root.closedIds = root.closedIds.filter(id => id !== notification.id);
    root.forget([notification]);
    notification.dismiss();
  }

  function removeAll() {
    const doomed = root.list.values.slice();
    root.closedIds = [];
    root.forget(doomed);

    for (const notification of doomed)
      notification.dismiss();
  }

  function forget(notifications) {
    for (const notification of notifications)
      delete root.received[notification.id];
  }

  // Dismissing mutates the model mid-iteration, so the victims are snapshotted
  // before any of them are destroyed. trackedNotifications is in arrival order,
  // so index 0 is the oldest.
  function enforceRetained() {
    const overflow = root.list.values.length - root.retainedLimit;
    if (overflow <= 0)
      return;

    const doomed = root.list.values.slice(0, overflow);
    root.closedIds = root.closedIds.filter(id => !doomed.some(n => n.id === id));
    root.forget(doomed);

    for (const notification of doomed)
      notification.dismiss();
  }

  function restore() {
    if (root.closedIds.length === 0)
      return false;

    root.closedIds = root.closedIds.slice(0, -1);
    return true;
  }

  // The default action, as makoctl invoke ran it on the top notification.
  function invoke() {
    const list = root.visible;
    if (list.length === 0)
      return false;

    root.activate(list[list.length - 1]);
    return true;
  }

  // One activation path for the toast click, the panel row click and invoke():
  // the default action when the sender offered one, else a best-effort focus of
  // a window matching the sender.
  function activate(notification) {
    if (!notification)
      return false;

    const action = notification.actions.find(a => a.identifier === "default");
    if (action)
      action.invoke();
    else
      Compositor.focusWindowFor(notification);

    return true;
  }

  property NotificationServer server: NotificationServer {
    // A notification is discarded unless something claims it, and both surfaces
    // need it to outlive the D-Bus call that delivered it.
    onNotification: notification => {
      notification.tracked = true;
      root.received[notification.id] = Date.now();
      CodeExtractor.scan(notification);
      root.enforceRetained();
    }

    bodySupported: true
    bodyMarkupSupported: true
    actionsSupported: true
    imageSupported: true
  }
}
