#!/usr/bin/env bash
# migrate.sh — run all migrations in order
#
# Migrations live in migrations/NNNNNN-*.sh and are sourced in lexicographic
# order. Each migration is idempotent and safe to re-run. Shared helpers live
# in migrations/_common.sh. There are no command-line arguments: conflicts are
# resolved by backing up the existing file (<dest>.bak.N) and symlinking.
#
# After migrations finish and you reboot into Hyprland, run:
#   ./setup.sh

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"
REPO_ROOT="$PWD"

# ---------------------------------------------------------------------------
# Logging — capture all output (stdout + stderr) to a timestamped log file
# while still printing to the terminal.
# ---------------------------------------------------------------------------
mkdir -p "$REPO_ROOT/logs"
LOG_FILE="$REPO_ROOT/logs/migrate-$(date +%Y%m%d-%H%M%S)-$$.log"
# Mirror output to the terminal (with color) AND to the log (ANSI escapes
# stripped for a clean, grep-friendly text file).
#
# Why a FIFO + background sed instead of nested process substitution
# (`>(tee >(sed ...))`): the previous nested form deadlocked at exit. The
# EXIT trap ran `wait` while the shell still held fd 1/2 open to the FIFO
# feeding `tee`, so `tee` never saw EOF, never exited, and `wait` hung
# forever (and the inner `sed` was a grandchild of the shell, so `wait`
# could not track it anyway).
#
# This design gives us a PID we can actually wait on: `sed` reads the FIFO
# and writes the stripped log; `tee` (a single process substitution) writes
# colored output to the terminal and raw output to the FIFO. In the EXIT
# trap we first restore the original stdout/stderr, which closes the shell's
# write-end of the `tee` FIFO -> `tee` sees EOF and exits -> the FIFO's only
# remaining write end closes -> `sed` sees EOF and exits -> `wait "$LOG_STRIP_PID"`
# returns. No race, no hang, and the log is complete before the prompt returns.
LOG_FIFO="$(mktemp -u "$REPO_ROOT/logs/.log-fifo-XXXXXX")"
mkfifo "$LOG_FIFO"
sed -E $'s/\x1b\[[0-9;]*m//g' < "$LOG_FIFO" >> "$LOG_FILE" &
LOG_STRIP_PID=$!
# Save the real stdout/stderr (fd 3/4) so the EXIT trap can restore them,
# closing the process-substitution FIFO and letting tee/sed drain.
exec 3>&1 4>&2
exec > >(tee "$LOG_FIFO") 2>&1
trap 'exec 1>&3 2>&4 3>&- 4>&-; wait "$LOG_STRIP_PID"; rm -f "$LOG_FIFO"' EXIT
echo "=== Migration started at $(date) ==="
echo "=== Log file: $LOG_FILE ==="

# shellcheck source=migrations/_common.sh
source "$REPO_ROOT/migrations/_common.sh"

preflight

section "Running Migrations"

shopt -s nullglob
_total=0
_failed=0
for _migration in "$REPO_ROOT"/migrations/[0-9][0-9][0-9][0-9][0-9][0-9]-*.sh; do
  _total=$((_total + 1))
  _name="$(basename "$_migration" .sh)"
  _results="$(mktemp "$REPO_ROOT/logs/.results-XXXXXX")"

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
    fail "migration exited $_rc — continuing to next migration: $_name"
    _add_error "migration failed: $_name (exit $_rc)"
  fi
done
shopt -u nullglob

echo ""
echo -e "  ${DIM}Ran $_total migration(s): $((_total - _failed)) ok, ${_failed} failed.${NC}"

print_summary
