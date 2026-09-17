# 000327-librewolf-webapps.sh -- LibreWolf taskbar-tab webapp launchers
# Installs: --
# Links:    --     (the templates live in the repo; nothing is symlinked)
# Writes:   ~/.local/share/applications/librewolf.webapp-<uuid>.desktop
#           (rendered from tracked $DOTFILES root/home/.config/librewolf/webapps/
#           *.desktop.tmpl templates)
# Enables:  --
# Note:     A LibreWolf taskbar tab (browser.taskbarTabs.enabled, enabled by
#           000326-librewolf-settings) creates a launcher whose Exec embeds
#           the machine-specific profile path (random prefix) and the tab's
#           UUID. Templates carry an @PROFILE_DIR@ placeholder which this
#           migration resolves from profiles.ini (same precedence as 000326),
#           so every machine renders the same launchers pointed at its own
#           profile. The rendered file is re-asserted on every run: if
#           LibreWolf rewrites it (webapp renamed or re-pinned in-browser),
#           the next ./migrate.sh reverts it -- keep changes by editing the
#           template.
#
#           Scope: this reproduces the LAUNCHER only. The tab registration,
#           icon, cookies and logins are browser profile state, not config;
#           on a fresh machine the first launch of the rendered launcher
#           opens the site as a taskbar tab and registers it from scratch.
#
#           Template format: '# uuid: <uuid>' header line (names the rendered
#           file librewolf.webapp-<uuid>.desktop, matching LibreWolf's own
#           naming) + a desktop entry with @PROFILE_DIR@ placeholders.
#
#           If LibreWolf has never been launched (no profile yet), this
#           migration skips with a warning; re-run ./migrate.sh after the
#           first launch.
#
# Idempotent: skips each launcher whose rendered content already matches.
#             Non-fatal: problems surface in the summary.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "librewolf webapp launchers (taskbar tabs)"

PROFILE_ROOT="$HOME/.config/librewolf/librewolf"
WEBAPPS_SRC="$DOTFILES_HOME/.config/librewolf/webapps"
APPS_DIR="$HOME/.local/share/applications"

# --- helper: resolve the ACTIVE profile dir from profiles.ini ---------------
# Same precedence as 000326-librewolf-settings.sh: [Install*] Default= wins
# over the legacy [Profile*] Default=1 marker; [Profile0] Path= last resort.
_lww_profile() {
    local ini="$PROFILE_ROOT/profiles.ini" p
    [[ -f "$ini" ]] || return 1

    p=$(awk -F= '
        /^\[Install/ { in_inst = 1; next }
        /^\[/         { in_inst = 0 }
        in_inst && $1 == "Default" { print $2; exit }
    ' "$ini")

    if [[ -z "$p" ]]; then
        p=$(awk -F= '
            BEGIN { found = "" }
            /^\[Profile/ {
                if (found == "" && prof_default == 1 && path != "") found = path
                in_prof = 1; prof_default = 0; path = ""; next
            }
            /^\[/         { in_prof = 0 }
            in_prof && $1 == "Default" && $2 == "1" { prof_default = 1 }
            in_prof && $1 == "Path" { path = $2 }
            END {
                if (found == "" && prof_default == 1 && path != "") found = path
                if (found != "") print found
            }
        ' "$ini")
    fi

    if [[ -z "$p" ]]; then
        p=$(awk -F= '
            /^\[Profile0\]/ { in0 = 1; next }
            /^\[/           { in0 = 0 }
            in0 && $1 == "Path" { print $2; exit }
        ' "$ini")
    fi

    [[ -n "$p" ]] || return 1
    [[ "$p" = /* ]] || p="$PROFILE_ROOT/$p"
    [[ -d "$p" ]] || return 1
    printf '%s\n' "$p"
}

# --- preconditions ------------------------------------------------------------
if ! ls "$WEBAPPS_SRC"/*.desktop.tmpl >/dev/null 2>&1; then
    skip "librewolf webapps (no templates tracked)"
    exit 0
fi

if ! _profile=$(_lww_profile); then
    warn "no LibreWolf profile found yet (LibreWolf never launched?) -- skipping"
    _add_warning "librewolf webapps: no profile yet; re-run migrate.sh after first launch"
    ok "nothing to do (no profile)"
    exit 0
fi

info "active profile: ${_profile/$HOME/\~}"
mkdir -p "$APPS_DIR"

# --- render each template -----------------------------------------------------
_rendered=0
for _tmpl in "$WEBAPPS_SRC"/*.desktop.tmpl; do
    _base="${_tmpl##*/}"
    # `|| true` is load-bearing: a template without the header makes grep -m1
    # exit 1, and under pipefail that aborts the migration before the graceful
    # empty-uuid skip below can handle it (same class as the gcx tag_name trap).
    _uuid=$(grep -m1 '^# *uuid:' "$_tmpl" 2>/dev/null | sed 's/^# *uuid: *//' | tr -d '[:space:]' || true)
    if [[ -z "$_uuid" ]]; then
        warn "template $_base has no '# uuid:' line -- skipping"
        _add_warning "librewolf webapp template missing uuid: $_base"
        continue
    fi

    _dest="$APPS_DIR/librewolf.webapp-$_uuid.desktop"
    _tmp="$(mktemp)"
    if ! sed -e "s|@PROFILE_DIR@|$_profile|g" "$_tmpl" >"$_tmp"; then
        warn "could not render template $_base"
        _add_warning "librewolf webapp render failed: $_base"
        rm -f "$_tmp"
        continue
    fi
    chmod 644 "$_tmp"

    if [[ -f "$_dest" ]] && cmp -s "$_tmp" "$_dest"; then
        skip "${_dest##*/} (up to date)"
        rm -f "$_tmp"
    else
        mv "$_tmp" "$_dest"
        ok "rendered ${_dest##*/}"
        _rendered=1
    fi
done

# Refresh the desktop database only when something changed (non-fatal).
if [[ "$_rendered" -eq 1 ]] && command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$APPS_DIR" 2>/dev/null || true
fi