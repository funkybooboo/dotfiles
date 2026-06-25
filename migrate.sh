#!/usr/bin/env bash
# migrate.sh — run all migrations in order
#
# Migrations live in migrations/NNNNNN-*.sh and are sourced in lexicographic
# order. Each migration is idempotent and safe to re-run. Shared helpers live
# in migrations/_common.sh. There are no command-line arguments: conflicts are
# resolved by backing up the existing file (<dest>.bak.N) and symlinking.
#
# After migrations finish and you reboot into Hyprland, run:
#   ./setup-secrets.sh

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"
REPO_ROOT="$PWD"

# shellcheck source=migrations/_common.sh
source "$REPO_ROOT/migrations/_common.sh"

preflight

section "Running Migrations"

shopt -s nullglob
for _migration in "$REPO_ROOT"/migrations/[0-9][0-9][0-9][0-9][0-9][0-9]-*.sh; do
  # shellcheck source=/dev/null
  source "$_migration"
done
shopt -u nullglob

print_summary
