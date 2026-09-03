# 000581-steam-opts-audit.sh -- Steam launch options audit (read-only reminder)
# Installs: --
# Links:    --
# Enables:  --
# Note: Steam does NOT sync per-game launch options between machines
#       (steam-for-linux #10475), so after a machine converges the games
#       still need Properties -> Launch Options set by hand. This migration
#       AUDITS instead of writing (editing localconfig.vdf under a running
#       Steam gets overwritten): it lists installed games (appmanifests,
#       with Steam's own runtimes/redists filtered by name) whose
#       localconfig.vdf LaunchOptions are missing or lack the canonical
#       gamescope+gamemoderun wrapper (README "Steam gaming"; the espanso
#       trigger :steamopts expands to it). Also flags leftover PROTON_LOG
#       debug options. Pure read-only: idempotent, converges nothing, and
#       surfaces drift as a migration warning so every ./migrate.sh run is
#       a per-game reminder.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "steam launch options audit"

STEAM_DIR="$HOME/.local/share/Steam"

if [ -d "$STEAM_DIR/steamapps" ]; then
  # 1) Installed games from app manifests. Skip Steam's own tool manifests:
  #    runtimes/redists/protons never take launch options. Name-matched so
  #    new tool appids are caught without maintaining an appid blocklist.
  declare -A GAME_NAME=()
  while IFS= read -r -d '' _manifest; do
    _appid=$(sed -n 's/^\t"appid"\t\t"\([0-9]*\)".*/\1/p' "$_manifest" | head -1)
    _name=$(sed -n 's/^\t"name"\t\t"\(.*\)".*/\1/p' "$_manifest" | head -1)
    [ -n "$_appid" ] || continue
    if printf '%s' "$_name" | grep -Eiq \
      '^(Steam Linux Runtime|Legacy Steam Runtime|Steamworks Common Redistributables|Proton|Steam Client Bootstrapper|SteamVR)'; then
      continue
    fi
    GAME_NAME[$_appid]="$_name"
  done < <(find "$STEAM_DIR/steamapps" -maxdepth 1 -name 'appmanifest_*.acf' -print0)

  # 2) Launch options per appid, merged across all Steam accounts
  #    (localconfig.vdf rewrites on Steam exit; reads are safe any time).
  declare -A APP_OPTS=()
  while IFS=$'\t' read -r _appid _opts; do
    [ -n "$_appid" ] || continue
    APP_OPTS[$_appid]="$_opts"
  done < <(
    for _lc in "$STEAM_DIR"/userdata/*/config/localconfig.vdf; do
      [ -f "$_lc" ] || continue
      awk '
        /^\t+"[0-9]+"[[:space:]]*$/ { _a = $0; gsub(/\t|"/, "", _a) }
        /^\t+"LaunchOptions"/ {
          _l = $0
          sub(/^.*"LaunchOptions"\t\t"/, "", _l)
          sub(/"$/, "", _l)
          print _a "\t" _l
        }
      ' "$_lc"
    done
  )

  # 3) Audit each installed game against the canonical wrapper.
  _missing=() _partial=() _stale_log=() _ok_count=0
  mapfile -t _ids < <(printf '%s\n' "${!GAME_NAME[@]}" | sort -n)
  for _appid in "${_ids[@]}"; do
    _name="${GAME_NAME[$_appid]}"
    _opts="${APP_OPTS[$_appid]:-}"
    if [ -z "$_opts" ]; then
      _missing+=("$_appid $_name")
      continue
    fi
    if printf '%s' "$_opts" | grep -q 'gamescope' \
       && printf '%s' "$_opts" | grep -q 'gamemoderun'; then
      _ok_count=$((_ok_count + 1))
    else
      _partial+=("$_appid $_name -- options: $_opts")
    fi
    if printf '%s' "$_opts" | grep -q 'PROTON_LOG'; then
      _stale_log+=("$_appid $_name")
    fi
  done

  _total=${#GAME_NAME[@]}
  if [ "$_total" -eq 0 ]; then
    skip "no installed Steam games found"
  elif [ "${#_missing[@]}" -eq 0 ] && [ "${#_partial[@]}" -eq 0 ]; then
    ok "launch options set on all $_total Steam game(s) (gamescope + gamemoderun)"
  else
    for _g in "${_missing[@]}"; do
      warn "no launch options: $_g -- Properties -> Launch Options -> type :steamopts"
    done
    for _g in "${_partial[@]}"; do
      warn "options missing gamescope/gamemoderun: $_g"
    done
    warn "$(( ${#_missing[@]} + ${#_partial[@]} )) of $_total game(s) need launch options (README: Steam gaming)"
    _add_warning "steam launch options: ${#_missing[@]} missing, ${#_partial[@]} partial -- set ':steamopts' per game"
  fi

  if [ "${#_stale_log[@]}" -gt 0 ]; then
    for _g in "${_stale_log[@]}"; do
      warn "debug leftover PROTON_LOG in options: $_g -- remove it"
    done
    _add_warning "steam: PROTON_LOG still in launch options for ${#_stale_log[@]} game(s)"
  fi
else
  skip "Steam not installed (000510 not applied) -- nothing to audit"
fi

ok "steam-opts-audit"