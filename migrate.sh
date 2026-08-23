#!/usr/bin/env bash
# migrate.sh — run all migrations in order
#
# Migrations live in migrations/NNNNNN-*.sh and are sourced in lexicographic
# order. Each migration is idempotent and safe to re-run. Shared helpers live
# in migrations/_common.sh. Conflicts are resolved by backing up the existing
# file (<dest>.bak.N) and symlinking.
#
# After migrations finish and you reboot into Hyprland, run:
#   ./setup.sh
#
# Usage: ./migrate.sh [-q|--quiet] [-h|--help]
#
# Flags:
#   -q, --quiet   Compact output for steady-state re-runs: collapses the
#                  per-migration section banners to one dim line and suppresses
#                  pacman's "up to date -- skipping" / "nothing to do" spam
#                  on no-op installs. Real installs, failures, warnings, and
#                  the final summary are unchanged. Also honors
#                  DOTFILES_QUIET=1. First installs should run without --quiet
#                  so you see full install output.
#   -h, --help    Show this help and exit.
#
# Interrupts: Ctrl+C (SIGINT) / SIGTERM abort the run cleanly. The first
# interrupt finishes the in-flight step and then stops; a second interrupt
# exits immediately with status 130. (Without this, the non-fatal subshell
# loop would swallow the signal and keep launching migrations — each one
# re-prompting for sudo — so Ctrl+C appeared to do nothing.)

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"
REPO_ROOT="$PWD"

# --- argument parsing ---------------------------------------------------------
_usage() {
  sed -n '2,28p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

case "${1:-}" in
  -h|--help)
    _usage
    exit 0
    ;;
  -q|--quiet)
    export _DOTFILES_QUIET=1
    ;;
  "")
    : # default (verbose) run
    ;;
  *)
    echo "migrate.sh: unknown argument: $1" >&2
    echo "usage: ./migrate.sh [-q|--quiet] [-h|--help]" >&2
    exit 2
    ;;
esac
# DOTFILES_QUIET=1 also enables quiet mode.
[[ "${DOTFILES_QUIET:-}" == "1" ]] && export _DOTFILES_QUIET=1

# Mirror all output to a log file (logs/ is gitignored). stdout+stderr still
# go to the terminal so you see progress in real time.
LOGDIR="$REPO_ROOT/logs"
mkdir -p "$LOGDIR"
LOGFILE="$LOGDIR/migrate-$(date +%Y%m%d-%H%M%S)-$$.log"
exec > >(tee -a "$LOGFILE") 2>&1

echo "=== Migration started at $(date) ==="
echo "=== Log: $LOGFILE ==="

# --- interrupt handling -------------------------------------------------------
# Each migration runs in a `set +e` subshell so one failure never aborts the
# run. That same design otherwise swallows Ctrl+C: the in-flight sudo dies, the
# subshell returns non-zero, and the loop happily starts the NEXT migration —
# which calls sudo again, re-prompts (timestamp never cached), and you get a
# spam loop you can't escape. The trap sets a flag the loop checks after each
# step; a second interrupt force-exits.
_INTERRUPTED=0
_abort_handler() {
  if (( _INTERRUPTED == 0 )); then
    _INTERRUPTED=1
    echo "" >&2
    warn "interrupt received — stopping after the current step (Ctrl+C again to force-exit)" >&2
  else
    echo "" >&2
    fail "second interrupt — exiting immediately" >&2
    exit 130
  fi
}
trap _abort_handler INT TERM

# shellcheck source=migrations/_common.sh
source "$REPO_ROOT/migrations/_common.sh"

preflight

section "Running Migrations"

shopt -s nullglob
_total=0
_failed=0
for _migration in "$REPO_ROOT"/migrations/[0-9][0-9][0-9][0-9][0-9][0-9]-*.sh; do
  if (( _INTERRUPTED )); then
    fail "aborted by interrupt before: $(basename "$_migration" .sh)"
    break
  fi
  _total=$((_total + 1))
  _name="$(basename "$_migration" .sh)"
  _results="$(mktemp)"

  # Run each migration in an isolated subshell with its own errexit so that a
  # failure in ONE migration can never abort the whole run — the previous
  # behaviour cascaded a single unguarded failure into every later migration
  # being skipped. Warnings/errors emitted inside the subshell are funnelled to
  # a results file (subshells cannot mutate the parent's arrays) and replayed
  # back into the parent afterwards so print_summary still reports them.
  set +e
  (
    set -euo pipefail
    _add_warning() { printf 'W:%s\n' "$*" >> "$_results"; }
    _add_error()   { printf 'E:%s\n' "$*" >> "$_results"; }
    # shellcheck source=/dev/null
    source "$_migration"
  )
  _rc=$?
  set -e

  # Replay collected warnings/errors into the parent shell's arrays.
  if [[ -s "$_results" ]]; then
    while IFS= read -r _line; do
      case "$_line" in
        W:*) _add_warning "${_line#W:}" ;;
        E:*) _add_error   "${_line#E:}" ;;
      esac
    done < "$_results"
  fi
  rm -f "$_results"

  if (( _rc != 0 )); then
    _failed=$((_failed + 1))
    if (( _INTERRUPTED )); then
      fail "aborted by interrupt during: $_name"
      _add_error "aborted by interrupt: $_name"
      break
    fi
    fail "migration exited $_rc — continuing to next migration: $_name"
    _add_error "migration failed: $_name (exit $_rc)"
  fi
done
shopt -u nullglob

echo ""
echo -e "  ${DIM}Ran $_total migration(s): $((_total - _failed)) ok, ${_failed} failed.${NC}"

print_summary
