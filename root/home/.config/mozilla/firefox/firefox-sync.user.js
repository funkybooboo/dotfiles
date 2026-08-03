// Applied on every Firefox startup. Values here override prefs.js and the UI.
// Self-hosted Firefox Sync (Option A): storage on CT 131, identity via Mozilla.
// Using the DIRECT tailnet IP:8000 (bypassing tailscale serve's https->http proxy)
// to isolate the "stream error: invalid Header provided" failures seen through
// https://syncstorage-rs.tail54538d.ts.net. If direct works, the proxy was the
// culprit and we can switch this back to the https URL later.
user_pref("identity.sync.tokenserver.uri", "http://100.123.239.50:8000/1.0/sync/1.5");