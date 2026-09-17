# 000326-librewolf-settings.sh -- LibreWolf profile settings via tracked user.js
# Installs: --     (librewolf itself is installed by 000307-librewolf)
# Links:    ~/.config/librewolf/librewolf/<active-profile>/user.js
#           -> $DOTFILES root/home/.config/librewolf/user.js
# Enables:  --
# Note:     Firefox-family browsers apply a user.js from the profile dir on
#           every launch, which makes tracked settings declarative: prefs
#           listed there are re-asserted at startup, so manual about:config
#           changes to them revert on next launch (edit the tracked file
#           instead). Settings locked by LibreWolf's shipped librewolf.cfg
#           cannot be overridden this way.
#
#           The profile dir has a machine-random name (xxxxxxxx.default-default),
#           so the link target is discovered at run time from profiles.ini:
#             1. [Install*] Default=  -- what the binary actually launches
#                (modern Firefox ignores the legacy [Profile*] Default=1 marker
#                when an Install section is present -- this machine has BOTH,
#                pointing at DIFFERENT profiles, so the Install section must
#                win).
#             2. [Profile*] Default=1 -- legacy marker, use that section's Path=
#             3. [Profile0] Path=      -- first profile, last resort
#           Values may be relative (IsRelative=1) or absolute.
#
#           If LibreWolf has never been launched (no profile yet), this
#           migration skips with a warning; re-run ./migrate.sh after the
#           first launch.
#
# Idempotent: skips when the profile user.js already points at the tracked
#             file. Non-fatal: problems surface in the summary.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "librewolf settings (user.js)"

PROFILE_ROOT="$HOME/.config/librewolf/librewolf"
TRACKED_USERJS="$DOTFILES_HOME/.config/librewolf/user.js"
TARGET_NAME="user.js"

# --- helper: resolve the ACTIVE profile dir from profiles.ini ---------------
# Prints the absolute profile dir on success; returns 1 when no usable profile
# exists. See the header comment for the precedence rationale.
_lws_profile() {
    local ini="$PROFILE_ROOT/profiles.ini" p
    [[ -f "$ini" ]] || return 1

    # 1. Install section Default= wins.
    p=$(awk -F= '
        /^\[Install/ { in_inst = 1; next }
        /^\[/         { in_inst = 0 }
        in_inst && $1 == "Default" { print $2; exit }
    ' "$ini")

    # 2. Legacy: the [Profile*] section carrying Default=1. Path= and
    # Default=1 may appear in EITHER order inside the section, so collect
    # both and flush at the next section boundary / EOF. Prints at most one
    # line (a found flag -- awk `exit` would still run END and double-print).
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

    # 3. Last resort: Profile0's Path.
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

if [[ ! -f "$TRACKED_USERJS" ]]; then
    fail "tracked settings file missing: ${TRACKED_USERJS/$HOME/\~}"
    _add_error "librewolf settings: tracked user.js missing from dotfiles"
    exit 1
fi

if ! _profile=$(_lws_profile); then
    warn "no LibreWolf profile found yet (LibreWolf never launched?) -- skipping"
    _add_warning "librewolf settings: no profile yet; re-run migrate.sh after first launch"
    ok "nothing to do (no profile)"
    exit 0
fi

_dest="$_profile/$TARGET_NAME"

if [[ -L "$_dest" && "$(readlink "$_dest")" == "$TRACKED_USERJS" ]]; then
    skip "user.js (already linked into ${_profile/$HOME/\~})"
    exit 0
fi

info "active profile: ${_profile/$HOME/\~}"
link_file "$TRACKED_USERJS" "$_dest"
if [[ -L "$_dest" && "$(readlink "$_dest")" == "$TRACKED_USERJS" ]]; then
    ok "user.js linked into profile (settings re-assert on every launch)"
    info "relaunch LibreWolf to apply on this session's prefs"
else
    fail "could not link user.js into $_profile"
    _add_error "librewolf settings: user.js link failed for ${_profile/$HOME/\~}"
    exit 1
fi