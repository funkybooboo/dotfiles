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

# Output goes straight to stdout/stderr -- no log-file mirroring. To capture
# a run, redirect yourself (./migrate.sh 2>&1 | tee my.log).

echo "=== Migration started at $(date) ==="

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
    fail "migration exited $_rc — continuing to next migration: $_name"
    _add_error "migration failed: $_name (exit $_rc)"
  fi
done
shopt -u nullglob

echo ""
echo -e "  ${DIM}Ran $_total migration(s): $((_total - _failed)) ok, ${_failed} failed.${NC}"

print_summary
