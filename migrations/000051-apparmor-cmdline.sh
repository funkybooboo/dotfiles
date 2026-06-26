# 000051-apparmor-cmdline.sh — add AppArmor LSM params to Limine cmdline
# Installs: —
# Links:    —
# Enables:  —
# Edits:    /boot/limine/limine.conf (appends to each `cmdline:` line)
#
# AppArmor is enabled as a service by 000050-apparmor.sh, but the LSM is not
# active unless the kernel is told to load it via the boot cmdline. This
# migration appends:
#
#     apparmor=1 lsm=landlock,lockdown,yama,integrity,apparmor,bpf
#
# to every `cmdline:` entry in /boot/limine/limine.conf. It is idempotent:
# entries that already contain `apparmor=1` are left untouched, so re-runs and
# hand-edited entries are never duplicated or clobbered. A reboot is required
# for the new cmdline to take effect.
#
# Safety design (boot config is high-value — a broken limine.conf = no boot):
#   * Refuse unless /boot is a mounted, writable filesystem (findmnt).
#   * Refuse if limine.conf is not a regular file (e.g. a symlink we'd break).
#   * Timestamped backup via `cp -a` before any change.
#   * The transform is written to a temp file and structurally validated
#     BEFORE the real file is touched: same line count, same number of
#     cmdline entries, every non-cmdline line byte-identical, every cmdline
#     line now contains apparmor=1 and is the original plus the param string.
#   * Deploy is an atomic same-filesystem rename (`mv -f`) from a root-owned
#     temp created next to the target, with owner/mode cloned from the
#     original via `--reference`. No partial writes can reach the real file.
#   * After deploy the file is re-read and re-verified; on any mismatch the
#     backup is restored and the migration reports failure.
#   * An EXIT trap removes all temp files even on abort/crash.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "AppArmor cmdline (Limine)"

LIMINE_CONF="/boot/limine/limine.conf"
APPARMOR_PARAMS="apparmor=1 lsm=landlock,lockdown,yama,integrity,apparmor,bpf"

# Temp paths held in globals so the EXIT trap can clean them up from any
# exit path (including set -e aborts).
_TMP_TRANSFORM=""
_TMP_DEPLOY=""

_cleanup() {
  [[ -n "$_TMP_TRANSFORM" && -f "$_TMP_TRANSFORM" ]] && rm -f "$_TMP_TRANSFORM"
  [[ -n "$_TMP_DEPLOY"   && -f "$_TMP_DEPLOY"   ]] && sudo rm -f "$_TMP_DEPLOY" 2>/dev/null || true
}
trap '_cleanup' EXIT

# ---------------------------------------------------------------------------
# Precondition checks
# ---------------------------------------------------------------------------

if ! findmnt --noheadings --output TARGET /boot >/dev/null 2>&1; then
  warn "/boot is not mounted — refusing to edit a possibly-stale mountpoint"
  _add_warning "/boot not mounted; AppArmor cmdline params not applied"
  # Non-fatal: nothing was changed. Other migrations continue.
  ok "nothing to do (/boot not mounted)"
  exit 0
fi

if ! findmnt --noheadings --options rw /boot >/dev/null 2>&1; then
  warn "/boot is mounted read-only — cannot edit limine.conf"
  _add_warning "/boot mounted read-only; AppArmor cmdline params not applied"
  exit 0
fi

if [[ ! -e "$LIMINE_CONF" ]]; then
  warn "$LIMINE_CONF not found — skipping (no Limine config to edit)"
  _add_warning "$LIMINE_CONF not found; AppArmor cmdline params not applied"
  exit 0
fi

if [[ -L "$LIMINE_CONF" || ! -f "$LIMINE_CONF" ]]; then
  warn "$LIMINE_CONF is not a regular file (symlink or special) — refusing to overwrite"
  _add_error "$LIMINE_CONF is not a regular file; AppArmor cmdline params not applied"
  fail "$LIMINE_CONF is not a regular file — skipping to avoid corrupting it"
  exit 1
fi

# ---------------------------------------------------------------------------
# Idempotency: count cmdline entries and how many already have apparmor=1.
# `grep -c` exits 1 on zero matches, which under `set -e` would abort the
# subshell — guard every count with `|| true`.
# ---------------------------------------------------------------------------

need_count=$(grep -cE '^[[:space:]]+cmdline:' "$LIMINE_CONF" 2>/dev/null || true)
have_count=$(grep -cE '^[[:space:]]+cmdline:.*apparmor=1' "$LIMINE_CONF" 2>/dev/null || true)

if (( need_count == 0 )); then
  warn "no 'cmdline:' entries found in $LIMINE_CONF — skipping"
  _add_warning "no cmdline entries in $LIMINE_CONF; AppArmor params not applied"
  exit 0
fi

if (( have_count == need_count )); then
  skip "$LIMINE_CONF (all $need_count cmdline entries already have apparmor=1)"
  exit 0
fi

orig_lines=$(wc -l < "$LIMINE_CONF" 2>/dev/null || true)

# ---------------------------------------------------------------------------
# Backup the original (timestamped, never overwrites an existing backup).
# ---------------------------------------------------------------------------

bak="${LIMINE_CONF}.bak.$(date +%s)"
while [[ -e "$bak" ]]; do
  bak="${LIMINE_CONF}.bak.$(date +%s).$RANDOM"
done
info "backing up $LIMINE_CONF -> $bak"
sudo cp -a "$LIMINE_CONF" "$bak"
if ! sudo cmp -s "$LIMINE_CONF" "$bak" 2>/dev/null; then
  fail "backup verification failed — aborting before any edit"
  _add_error "limine.conf backup did not verify; no changes made"
  exit 1
fi

# ---------------------------------------------------------------------------
# Transform: write the new content to a user-owned temp file. Only
# `cmdline:` lines lacking `apparmor=1` are changed; every other line is
# printed verbatim. Trailing whitespace is trimmed before appending so we
# never introduce a double space if a line was already padded.
# ---------------------------------------------------------------------------

_TMP_TRANSFORM="$(mktemp)"
awk -v params="$APPARMOR_PARAMS" '
  /^[[:space:]]+cmdline:/ && $0 !~ /apparmor=1/ {
    sub(/[[:space:]]+$/, "")
    print $0 " " params
    next
  }
  { print }
' "$LIMINE_CONF" > "$_TMP_TRANSFORM"

# ---------------------------------------------------------------------------
# Validate the transform BEFORE touching the real file. Five invariants:
#   1. temp is non-empty and same line count as the original
#   2. same number of cmdline entries (none added/dropped)
#   3. every non-cmdline line is byte-identical to the original
#   4. every cmdline line now contains apparmor=1
#   5. every cmdline line is exactly "<original cmdline> <params>"
# Invariant 5 is checked by re-deriving the expected line and comparing,
# which also catches any accidental truncation or reordering.
# ---------------------------------------------------------------------------

_validate_error=""

new_lines=$(wc -l < "$_TMP_TRANSFORM" 2>/dev/null || true)
if (( new_lines != orig_lines )); then
  _validate_error="line count changed: $orig_lines -> $new_lines"
fi

new_cmdline_count=$(grep -cE '^[[:space:]]+cmdline:' "$_TMP_TRANSFORM" 2>/dev/null || true)
if [[ -z "$_validate_error" ]] && (( new_cmdline_count != need_count )); then
  _validate_error="cmdline entry count changed: $need_count -> $new_cmdline_count"
fi

new_have_count=$(grep -cE '^[[:space:]]+cmdline:.*apparmor=1' "$_TMP_TRANSFORM" 2>/dev/null || true)
if [[ -z "$_validate_error" ]] && (( new_have_count != need_count )); then
  _validate_error="not all cmdline entries have apparmor=1 after transform: $new_have_count/$need_count"
fi

# Independent structural check: strip cmdline lines from both files and
# compare. If anything other than a cmdline line changed, this differs.
if [[ -z "$_validate_error" ]]; then
  if ! diff <(grep -vE '^[[:space:]]+cmdline:' "$LIMINE_CONF") \
            <(grep -vE '^[[:space:]]+cmdline:' "$_TMP_TRANSFORM") >/dev/null 2>&1; then
    _validate_error="non-cmdline content changed in transform"
  fi
fi

# Strongest check: re-derive each expected cmdline line and compare it to the
# transformed one. Catches truncation, reordering, or wrong param text.
if [[ -z "$_validate_error" ]]; then
  expected_cmdlines_file="$(mktemp)"
  awk -v params="$APPARMOR_PARAMS" '
    /^[[:space:]]+cmdline:/ && $0 !~ /apparmor=1/ {
      sub(/[[:space:]]+$/, ""); print $0 " " params; next
    }
    /^[[:space:]]+cmdline:/ { print }
  ' "$LIMINE_CONF" > "$expected_cmdlines_file"

  if ! diff <(grep -E '^[[:space:]]+cmdline:' "$LIMINE_CONF" | awk '
      /^[[:space:]]+cmdline:/ && $0 !~ /apparmor=1/ {
        sub(/[[:space:]]+$/, ""); print $0 " '"$APPARMOR_PARAMS"'"; next
      }
      { print }
    ') <(grep -E '^[[:space:]]+cmdline:' "$_TMP_TRANSFORM") >/dev/null 2>&1; then
    _validate_error="cmdline lines do not match expected transform"
  fi
  rm -f "$expected_cmdlines_file"
fi

if [[ -n "$_validate_error" ]]; then
  fail "transform validation failed: $_validate_error"
  fail "no changes written to $LIMINE_CONF (original untouched)"
  _add_error "limine.conf transform rejected: $_validate_error"
  exit 1
fi

# ---------------------------------------------------------------------------
# Deploy atomically. Create a root-owned temp ON THE SAME FILESYSTEM as the
# target (so `mv` is an atomic rename, not a copy), clone owner/mode from
# the original, then rename over the real file.
# ---------------------------------------------------------------------------

_TMP_DEPLOY="$(sudo mktemp /boot/limine/.limine.conf.XXXXXX)"
if [[ -z "$_TMP_DEPLOY" ]]; then
  fail "could not create deploy temp in /boot/limine"
  _add_error "could not create deploy temp; no changes made"
  exit 1
fi

sudo cp "$_TMP_TRANSFORM" "$_TMP_DEPLOY"
sudo chown --reference="$LIMINE_CONF" "$_TMP_DEPLOY"
sudo chmod --reference="$LIMINE_CONF" "$_TMP_DEPLOY"

# Pre-rename integrity check on the deploy temp.
if ! sudo cmp -s "$_TMP_DEPLOY" "$_TMP_TRANSFORM" 2>/dev/null; then
  fail "deploy temp does not match transform — aborting"
  _add_error "deploy temp verification failed; no changes made"
  exit 1
fi

sudo mv -f "$_TMP_DEPLOY" "$LIMINE_CONF"
_TMP_DEPLOY=""   # consumed by the rename; nothing for the trap to remove

# ---------------------------------------------------------------------------
# Post-deploy verification: re-read the real file and confirm the result.
# If anything is wrong, restore from the backup and fail loudly.
# ---------------------------------------------------------------------------

post_lines=$(wc -l < "$LIMINE_CONF" 2>/dev/null || true)
post_cmdline=$(grep -cE '^[[:space:]]+cmdline:' "$LIMINE_CONF" 2>/dev/null || true)
post_have=$(grep -cE '^[[:space:]]+cmdline:.*apparmor=1' "$LIMINE_CONF" 2>/dev/null || true)

post_ok=1
if (( post_lines != orig_lines )); then
  post_ok=0; fail "post-deploy line count mismatch: $orig_lines -> $post_lines"
fi
if (( post_cmdline != need_count )); then
  post_ok=0; fail "post-deploy cmdline count mismatch: $need_count -> $post_cmdline"
fi
if (( post_have != need_count )); then
  post_ok=0; fail "post-deploy: only $post_have/$need_count cmdline entries have apparmor=1"
fi
# Confirm non-cmdline content survived the rename intact.
if ! diff <(grep -vE '^[[:space:]]+cmdline:' "$bak") \
          <(grep -vE '^[[:space:]]+cmdline:' "$LIMINE_CONF") >/dev/null 2>&1; then
  post_ok=0; fail "post-deploy: non-cmdline content differs from backup"
fi

if (( post_ok != 1 )); then
  fail "post-deploy verification failed — restoring $LIMINE_CONF from $bak"
  sudo cp -a "$bak" "$LIMINE_CONF"
  if sudo cmp -s "$bak" "$LIMINE_CONF" 2>/dev/null; then
    warn "restored $LIMINE_CONF from backup"
  else
    fail "RESTORE FAILED — $LIMINE_CONF may be corrupt; backup at $bak"
  fi
  _add_error "limine.conf deploy failed; restored from backup ($bak)"
  exit 1
fi

ok "appended '$APPARMOR_PARAMS' to $((post_have - have_count)) cmdline entry/entries"
info "backup at $bak"
warn "reboot required for AppArmor LSM to become active"
_add_warning "AppArmor cmdline params added to limine.conf — reboot to activate"
