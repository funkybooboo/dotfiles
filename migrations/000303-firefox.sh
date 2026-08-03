# 000303-firefox.sh -- Firefox web browser (pacman) + firefox-sync user.js
# Installs: firefox
# Links:   ~/.config/mozilla/firefox/<*.default-release>/user.js
#          -> firefox-sync.user.js (identity.sync.tokenserver.uri = self-hosted
#             syncstorage-rs on CT 131 tailnet 100.123.239.50:8000)
# Enables: --
# Note: one piece of software = one migration. The other browsers live in
#       000309-chromium, 000313-brave, 000307-librewolf, 000308-mullvad-browser.
#       Firefox is the Arch official build (extra/, GPG-signed).
#       Firefox profile dirs have random per-install names (*.default-release),
#       so this migration globs each one and links the tracked user.js in as
#       <profile>/user.js -- applied on every startup, sticky across machines.
#       Non-fatal if no profile exists yet (Firefox makes it on first launch;
#       re-run ./migrate.sh after).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "firefox"

install_pacman firefox

# Link the self-hosted-sync tokenserver pref into every existing default-release
# profile. Firefox reads <profile>/user.js at startup and forces these prefs
# (overrides prefs.js + the about:config UI), so the pref cannot be silently
# dropped. The direct tailnet IP is portable across every machine joined to
# the tail54538d tailnet.
_tracked_userjs="$DOTFILES_HOME/.config/mozilla/firefox/firefox-sync.user.js"
_ff_root="$HOME/.config/mozilla/firefox"
if [[ -d "$_ff_root" ]]; then
  for _prof in "$_ff_root"/*.default-release; do
    [[ -d "$_prof" ]] || continue
    link_file "$_tracked_userjs" "$_prof/user.js"
  done
else
  info "no ~/.config/mozilla/firefox yet; firefox-sync user.js will link on next migrate after first Firefox launch"
fi

ok "firefox"