// Applied on every LibreWolf startup. Values here override prefs.js and the UI.
// Self-hosted Firefox Sync (Option A): storage on CT 131, identity via Mozilla
// (accounts.firefox.com). LibreWolf ships HTTPS-Only mode ON (locked via
// policy HttpsOnlyMode=enabled), so the URI MUST be https -- an http:// URI
// gets auto-upgraded to https against a plain-HTTP port and fails with
// TokenServerClientNetworkError (and syncstorage-rs logs "stream error:
// invalid Header provided" because hyper sees the TLS ClientHello bytes).
// The https URL goes through tailscale serve (TLS on 443) and works.
//
// The matching server-side knob is SYNC_TOKENSERVER__INIT_NODE_URL on CT 131
// (the node URL syncstorage-rs's tokenserver returns to the browser for
// storage requests) -- it must also be https for the same HTTPS-Only reason.
user_pref("identity.sync.tokenserver.uri", "https://syncstorage-rs.tail54538d.ts.net/1.0/sync/1.5");