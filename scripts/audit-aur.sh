#!/usr/bin/env bash
# audit-aur.sh — fetch + scan an AUR PKGBUILD for the "audited in-tree
# PKGBUILD" workflow.
#
# Per repo policy: anything installed from the AUR must be vendored into
# pkgbuilds/ and audited (a human reads the PKGBUILD + co-located files once,
# records the audit in AUDIT.md). This script is the *human-assist* half — it
# automates the legwork (fetch, suspicious-pattern scan, upstream-sha256
# cross-check) and prints a draft AUDIT.md for the human to read, edit, and
# commit. It does NOT make trust decisions itself; "verify trust" for a
# prebuilt upstream binary is a human judgment call the script surfaces
# evidence for, not a computation it can complete.
#
# Run as your normal user; no sudo.
#
# Usage:
#   scripts/audit-aur.sh <aur-pkgname>            # draft AUDIT.md to stdout
#   scripts/audit-aur.sh <aur-pkgname> -o pkgbuilds/<pkg>/AUDIT.md   # write it
#
# What this checks (the achievable integrity ceiling for binary downloads +
# the packaging-script surface):
#   1. Suspicious-pattern scan of the PKGBUILD + every co-located file:
#        curl|sh / curl|bash / wget|sh, $(curl …), eval of dynamic vars,
#        non-https source= URLs, /etc/passwd|/etc/shadow writes, SUID bits,
#        post_install touching $HOME, systemctl --user in install hooks.
#   2. source=() URLs printed with provenance hints (github, codeberg, gitlab,
#      pypi, npm — flagged UNKNOWN otherwise).
#   3. For each https:// source URL: download it, sha256 it, compare against
#      the AUR-published sha256sums(_x86_64|_aarch64) entry at the same index.
#   4. validpgpkeys present? -> noted (GPG signature is stronger than sha256).
#
# Honest limitations (also printed in the draft):
#   * The contents of a prebuilt upstream binary are NOT auditable by this or
#     any package manager. The ceiling is sha256-pinned (+ GPG-signed when the
#     publisher provides one). The human reads AUDIT.md and judges whether the
#     upstream URL is "the real upstream".
#   * Pattern matching is conservative; expect false positives the human
#     judges benign (e.g. a setuid chrome-sandbox is expected for Chromium).

set -uo pipefail

usage() {
  cat <<EOF
Usage: $0 <aur-pkgname> [-o <output-audit-md>]

Fetch + scan an AUR PKGBUILD for an audited in-tree PKGBUILD workflow.
Prints a draft AUDIT.md to stdout (or writes to -o path). Non-fatal, non-sudo.
EOF
  exit "${1:-0}"
}

AUR_PKG="${1:-}"
OUT=""
if [[ "${2:-}" == "-o" ]]; then OUT="${3:-}"; fi
[[ -n "$AUR_PKG" ]] || usage 1

command -v curl >/dev/null 2>&1 || { echo "curl required" >&2; exit 1; }
command -v makepkg >/dev/null 2>&1 || { echo "makepkg required (base-devel)" >&2; exit 1; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

AUR_CGIT="https://aur.archlinux.org/cgit/aur.git/plain"
if ! curl -fsSL "$AUR_CGIT/PKGBUILD?h=$AUR_PKG" -o "$TMP/PKGBUILD" 2>/dev/null; then
  echo "ERROR: AUR package '$AUR_PKG' not found (PKGBUILD fetch failed)" >&2
  exit 1
fi
echo "Fetched PKGBUILD for $AUR_PKG -> $TMP/PKGBUILD" >&2
# makepkg --printsrcinfo refuses to parse a PKGBUILD whose `install=` file is
# absent ("install file … does not exist"). Stage co-located install files
# (the PKGBUILD's `install=` is a single filename) as empty placeholders so
# SRCINFO emission succeeds; their real content is fetched + scanned below as
# co-located files.
_inst_line="$(grep -E '^[[:space:]]*install=' "$TMP/PKGBUILD" | head -1)"
if [[ -n "$_inst_line" ]]; then
  _i="${_inst_line#*install=}"
  _i="${_i//\'/}"; _i="${_i//\"/}"   # strip surrounding quotes
  _i="${_i%% #*}"; _i="${_i%%#*}"    # trailing comment (if any)
  _i="${_i/\$\{pkgname\}/${AUR_PKG%-bin}}" # expand ${pkgname} if used
  _i="${_i/\$pkgname/${AUR_PKG%-bin}}"
  [[ -n "$_i" ]] && : > "$TMP/$_i"   # empty placeholder
fi
SRCINFO="$(cd "$TMP" && makepkg --printsrcinfo 2>/dev/null || true)"

# --- parse SRCINFO alignment-by-position -------------------------------------
# SRCINFO emits each array entry on its own line in declaration order, so
# source[i] lines up positionally with sha256sums[i] (and _x86_64 / _aarch64
# variants likewise). Easier + safer than re-sourcing the PKGBUILD live.
SRC_TOP=();       SHA_TOP=()
SRC_x86_64=();    SHA_x86_64=()
SRC_aarch64=();   SHA_aarch64=()
ALL_SOURCES=()
COLOCATED=()
VALIDPGPKEYS=()

# Print the value of every repeated `key = value` line in SRCINFO (array entries
# emit one line each, in order). Field separator splits on the surrounding
# whitespace so the leading tab is stripped from $1.
srcinfo_kv() {
  awk -F'[[:space:]]*=[[:space:]]*' -v key="$1" '
    /^\t/ { sub(/^\t/, "", $1) }
    $1==key { print $2 }
  ' <<<"$SRCINFO"
}

# populate: top-level
mapfile -t SRC_TOP       < <(srcinfo_kv source)
mapfile -t SHA_TOP       < <(srcinfo_kv sha256sums)
mapfile -t SRC_x86_64    < <(srcinfo_kv source_x86_64)
mapfile -t SHA_x86_64    < <(srcinfo_kv sha256sums_x86_64)
mapfile -t SRC_aarch64   < <(srcinfo_kv source_aarch64)
mapfile -t SHA_aarch64   < <(srcinfo_kv sha256sums_aarch64)
mapfile -t VALIDPGPKEYS  < <(srcinfo_kv validpgpkeys)
ALL_SOURCES+=("${SRC_TOP[@]:-}" "${SRC_x86_64[@]:-}" "${SRC_aarch64[@]:-}")

# Co-located = a top-level source entry with no URL scheme (a file shipped in
# the AUR repo alongside the PKGBUILD). We fetch each from the AUR and scan it
# too, so the human reviews the actual bytes that makepkg will run.
is_url() {
  case "$1" in
    http://*|https://*|git+*|ftp://*|file://*|*::*) return 0 ;;
    *) return 1 ;;
  esac
}
for s in "${SRC_TOP[@]:-}"; do
  [[ -z "$s" ]] && continue
  if ! is_url "$s"; then COLOCATED+=("$s"); fi
done

# --- suspicious-pattern scan -------------------------------------------------
PATTERNS=(
  'curl\b[^|]*\|\s*(sh|bash)'   # curl|sh
  'wget\b[^|]*\|\s*(sh|bash)'   # wget|sh
  '\$\(\s*curl\s'               # $(curl ...)
  '\$\(\s*wget\s'               # $(wget ...)
  '\beval\b\s+\$'               # eval of dynamic var
  'http://'                     # plain http (review source= carefully)
  '/etc/passwd'
  '/etc/shadow'
  'chmod\s+[0-9]?4[0-9][0-9][0-9]\b'   # SUID/SGID (setuid chrome-sandbox)
  '(\$\{?HOME\b|~/\.)'                  # $HOME / ~/. writes in install hooks
  'systemctl\b.*--user'                 # user-session enablement at install time
  'nc\s+-l'
  '/dev/tcp'
  'tee\s+/etc/'
)
SCAN_FILES=("$TMP/PKGBUILD")
for s in "${COLOCATED[@]:-}"; do
  [[ -z "$s" ]] && continue
  if curl -fsSL "$AUR_CGIT/$s?h=$AUR_PKG" -o "$TMP/$s" 2>/dev/null; then
    SCAN_FILES+=("$TMP/$s")
  fi
done

rm -f "$TMP/suspicious.txt"
for f in "${SCAN_FILES[@]}"; do
  for pat in "${PATTERNS[@]}"; do
    while IFS= read -r matchline; do
      [[ -z "$matchline" ]] && continue
      printf '%s:%s\n' "${f##*/}" "$matchline" >> "$TMP/suspicious.txt"
    done < <(grep -nE "$pat" "$f" 2>/dev/null)
  done
done

# --- sha256 cross-check ------------------------------------------------------
CROSSCHECK=""
crosscheck_one() {
  local arch="$1"   # "" / x86_64 / aarch64
  local -n src_arr="SRC_${arch:-TOP}"
  local -n sha_arr="SHA_${arch:-TOP}"
  local n=${#src_arr[@]}
  local i url sha actual raw
  for (( i=0; i<n; i++ )); do
    raw="${src_arr[$i]}"
    url="$raw"
    [[ "$raw" == *::* ]] && url="${raw#*::}"
    [[ "$url" == https://* ]] || continue
    sha="${sha_arr[$i]:-<none-published>}"
    if ! curl -fsSL "$url" -o "$TMP/blob.bin" 2>/dev/null; then
      CROSSCHECK+="- [$arch] $url  DOWNLOAD-FAILED"$'\n\n'
      continue
    fi
    actual="$(sha256sum "$TMP/blob.bin" | awk '{print $1}')"
    rm -f "$TMP/blob.bin"
    local mark="OK"
    if [[ "${sha,,}" == "skip" ]]; then mark="SKIP-PUBLISHED"; sha="(AUR: SKIP — GPG/other)"
    elif [[ "$sha" == "<none-published>" ]]; then mark="NO-PUBLISHED-SHA"
    elif [[ "$actual" != "$sha" ]]; then mark="MISMATCH"
    fi
    CROSSCHECK+="- [$arch] $url"$'\n'"    actual:   $actual"$'\n'"    aur sha: $sha"$'\n'"    -> $mark"$'\n\n'
  done
}
crosscheck_one ""
crosscheck_one x86_64
crosscheck_one aarch64

# --- provenance hints --------------------------------------------------------
PROVENANCE=""
provenance_hint() {
  local s="$1" u="$1"
  [[ "$s" == *::* ]] && u="${s#*::}"
  case "$u" in
    https://github.com/*/*|git+https://github.com/*/*) echo "- $s  (github; verify org)" ;;
    https://codeberg.org/*|git+https://codeberg.org/*) echo "- $s  (codeberg; LibreWolf channel)" ;;
    https://gitlab.com/*/*) echo "- $s  (gitlab.com; verify project)" ;;
    https://files.pythonhosted.org/*|https://pypi.org/*) echo "- $s  (PyPI)" ;;
    https://registry.npmjs.org/*|https://www.npmjs.com/*) echo "- $s  (npm registry)" ;;
    https://*) echo "- $s  (https; VERIFY-UPSTREAM-DOMAIN)" ;;
    http://*)  echo "- $s  (PLAIN HTTP -- suspicious)" ;;
    git+*|git://*) echo "- $s  (git VCS source; check remote)" ;;
    *) echo "- $s  (co-located file shipped by AUR)" ;;
  esac
}
for s in "${ALL_SOURCES[@]:-}"; do
  [[ -z "$s" ]] && continue
  PROVENANCE+="$(provenance_hint "$s")"$'\n'
done

# --- validpgpkeys ------------------------------------------------------------
PGP=""
if [[ ${#VALIDPGPKEYS[@]} -gt 0 ]]; then
  PGP="validpgpkeys set (GPG signature verified by makepkg; confirm these key"
  PGP="$PGP ids are published by upstream):"$'\n'
  for k in "${VALIDPGPKEYS[@]}"; do PGP+="  - $k"$'\n'; done
fi

# --- draft AUDIT.md ----------------------------------------------------------
{
  echo "# Audit — ${AUR_PKG}"
  echo
  echo "Audited $(date +%F) by <AUDITOR>. Draft generated by scripts/audit-aur.sh."
  echo "Fill in the provenance verification + the packaging-script review before"
  echo "committing. The DRAFT records automated checks; the human reading is the"
  echo "actual audit."
  echo
  echo "## Provenance"
  echo
  echo "$PROVENANCE"
  echo
  echo "## Integrity cross-check (downloaded sha256 vs AUR-published sha256)"
  echo
  if [[ -z "$CROSSCHECK" ]]; then
    echo "_(no https:// sources to cross-check — git-VCS / co-located files only)_"
  else
    echo "$CROSSCHECK"
  fi
  echo
  echo "## GPG signatures"
  echo
  if [[ -z "$PGP" ]]; then
    echo "_(no validpgpkeys set — integrity is sha256-only; same level as"
    echo "flatpak TLS transport)_."
  else
    echo "$PGP"
  fi
  echo
  echo "## Suspicious-pattern scan (false positives expected — review each)"
  echo
  if [[ -s "$TMP/suspicious.txt" ]]; then
    echo '```'
    cat "$TMP/suspicious.txt"
    echo '```'
  else
    echo "_No suspicious patterns matched in PKGBUILD or co-located files._"
  fi
  echo
  echo "## Co-located files to read"
  echo
  if [[ ${#COLOCATED[@]} -eq 0 ]]; then
    echo "_(none)_"
  else
    printf -- '- %s\n' "${COLOCATED[@]}"
  fi
  echo
  echo "## Human review steps"
  echo
  echo "1. For each source URL above, open the upstream website and confirm it"
  echo "   links to the same artifact host (provenance)."
  echo "2. Read the PKGBUILD's build()/package() once: no \`curl|sh\`, no \`eval\`"
  echo "   of remote content, no network in build, no post_install touching \$HOME,"
  echo "   no surprising setuid."
  echo "3. If validpgpkeys is set, confirm the key id is published by upstream"
  echo "   (upstream README / security page)."
  echo "4. Read each co-located file above (fetched + scanned already — the scan"
  echo "   only catches known patterns, not intent)."
  echo "5. Delete this template footer and write a one-paragraph conclusion under"
  echo "   a Notes section."
} > "$TMP/AUDIT.md"

if [[ -n "$OUT" ]]; then
  mkdir -p "$(dirname "$OUT")"
  cp "$TMP/AUDIT.md" "$OUT"
  echo "Wrote $OUT" >&2
else
  cat "$TMP/AUDIT.md"
fi
echo "Done." >&2
exit 0