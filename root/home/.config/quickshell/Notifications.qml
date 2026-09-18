pragma Singleton
import Quickshell
import Quickshell.Services.Notifications

// Replaces mako as the notification daemon. Geometry, colours and timeouts are
// ported from mako/config; the popups themselves live in NotificationLayer.
Singleton {
  id: root

  // mako's `set-mode dnd` kept receiving notifications and only stopped showing
  // them, so this suppresses the popup rather than the tracking.
  property bool doNotDisturb: false

  readonly property var list: server.trackedNotifications

  // Closed notifications are kept tracked and merely hidden, oldest first, so
  // `restore` can bring one back complete with its actions -- calling dismiss()
  // untracks and destroys the object, leaving nothing to restore but a copy.
  // The cost is that the sender does not learn a notification was closed until it
  // is evicted, which is why the retained set is bounded rather than unbounded.
  property var closedIds: []

  readonly property int retainedLimit: 20

  readonly property var visible: root.list.values.filter(n => !root.closedIds.includes(n.id))

  function close(notification) {
    root.closedIds = [...root.closedIds, notification.id];

    while (root.closedIds.length > root.retainedLimit) {
      const evictedId = root.closedIds[0];
      root.closedIds = root.closedIds.slice(1);

      const evicted = root.list.values.find(n => n.id === evictedId);
      if (evicted)
        evicted.dismiss();
    }
  }

  function closeAll() {
    for (const notification of root.visible)
      root.close(notification);
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

    const notification = list[list.length - 1];
    const action = notification.actions.find(a => a.identifier === "default");

    if (!action)
      return false;

    action.invoke();
    return true;
  }

  property NotificationServer server: NotificationServer {
    // A notification is discarded unless something claims it, and the popup
    // needs it to outlive the D-Bus call that delivered it.
    onNotification: notification => {
      notification.tracked = true;
      CodeExtractor.scan(notification);
    }

    bodySupported: true
    bodyMarkupSupported: true
    actionsSupported: true
    imageSupported: true
  }
}
