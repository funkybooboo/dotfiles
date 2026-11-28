// LibreWolf profile settings -- tracked in ~/dotfiles, deployed as a user.js
// symlink into the active LibreWolf profile by migrations/000326-librewolf-settings.sh.
//
// How this works: Firefox-family browsers apply user.js from the profile dir
// on EVERY launch. Prefs listed here are therefore declarative -- manual
// about:config changes to them are reverted at the next launch. To change a
// pref, edit this file and re-run ./migrate.sh (or just relaunch if the link
// is already in place -- the file is read at every startup).
//
// Limits: settings locked by LibreWolf's shipped /opt/librewolf/librewolf.cfg
// (lockPref entries) cannot be overridden here. Everything else, including
// LibreWolf's defaultPref hardening defaults, can.

// Taskbar tabs: pin a tab as its own taskbar entry ("Install page as app").
// browser.taskbar.previews.enable restores window preview thumbnails for the
// pinned taskbar entry. Both are off by default in LibreWolf 153.
user_pref("browser.taskbarTabs.enabled", true);
user_pref("browser.taskbar.previews.enable", true);

// Firefox sync -> the homelab, not Mozilla's servers (USER-5). The
// tokenserver validates your FxA login token and mints storage
// credentials for OUR syncstorage-rs; the data (client-side
// encrypted before upload) lands in the mysql guest on
// pve-thermaltake. Revert = remove these two lines and relaunch
// (the old Mozilla sync state is untouched either way).
user_pref("identity.sync.tokenserver.uri", "https://sync.tail54538d.ts.net/1.0/sync/1.5");