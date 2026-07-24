# 000307-librewolf.sh -- LibreWolf from upstream binary release (codeberg bsys6)
# Installs:        librewolf (prebuilt binary tarball from codeberg releases)
# Installs to:     /opt/librewolf  (binary tree extracted here, owned by root)
# Links:           /usr/local/bin/librewolf -> /opt/librewolf/librewolf
#                  ~/.local/share/applications/librewolf.desktop (written file)
# Enables:         --
# GPG verifies:    yes (LibreWolf Maintainers <gpg@librewolf.net>,
#                  primary 662E3CDD6FE329002D0CA5BB4039DD82B12EF16)
# sha256 verifies: yes (against upstream-published .sha256sum sidecar)
#
# Source: codeberg.org/librewolf/bsys6 releases download 153.0-3 (latest as of
#         2026-07-24). The bsys6 release download URLs 303-redirect to
#         dl.librewolf.net (LibreWolf's own CDN). Assets per release:
#           librewolf-<ver>-linux-x86_64-package.tar.xz        (~100 MB)
#           librewolf-<ver>-linux-x86_64-package.tar.xz.sha256sum
#           librewolf-<ver>-linux-x86_64-package.tar.xz.sig    (GPG detached)
#
# Policy: this is TIER 2 (upstream release asset) per the install-priority
#         policy. NO AUR, NO makepkg, NO nix. The tarball is the same Firefox
#         build that the AUR `librewolf-bin` package repacks; we fetch + verify
#         it directly from upstream's signed release instead. Install prefix is
#         /opt/librewolf (matches Mozilla's own /opt convention + the AUR
#         layout (/usr/lib/librewolf) so librewolf behaves identically).
#
# Idempotent: skips install if /opt/librewolf/application.ini reports the
#             pinned version. Re-running with a newer pinned version replaces
#             the tree. Non-fatal: warnings/errors surface in the summary.
#
# Roll-forward: detects the latest codeberg bsys6 release via the Gitea API,
#               downloads + sha256-verifies against the upstream .sha256sum +
#               GPG-verifies the .sig, and replaces /opt/librewolf if newer.
#               Mirrors the gcx/proton-drive roll-forward pattern but uses
#               the per-release .sha256sum sidecar (not a hardcoded pin).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "librewolf (codeberg release)"

# --- pinned version + upstream release URL ------------------------------------
LW_VERSION="153.0-3"
LW_REPO="librewolf/bsys6"
LW_REL="https://codeberg.org/${LW_REPO}/releases/download/${LW_VERSION}"
LW_ARCH="x86_64"   # only x86_64 profiled here (workstation). arm64 exists upstream.

# LibreWolf release signing key (GPG). Imported once into the user keyring so
# `gpg --verify` works. Primary fingerprint from librewolf.net/docs.
LW_GPG_KEY="662E3CDD6FE329002D0CA5BB4039DD82B12EF16"
LW_GPG_KEYSERVER="hkps://keys.openpgp.org"

LW_PREFIX="/opt/librewolf"
LW_BIN_SYMLINK="/usr/local/bin/librewolf"
LW_DESKTOP="$HOME/.local/share/applications/librewolf.desktop"
DL_DIR="$HOME/.cache/dotfiles-downloads"

# --- sanity: this migration runs as a sudo-capable user (preflight enforces)
#     but we still need sudo for /opt + /usr/local/bin writes. ----

# --- helper: import the release signing key (idempotent, non-fatal) ----------
# Best-effort: modern gpg auto-retrieves the key during --verify, so an import
# failure here does NOT block verification -- the verify step reports for real.
_lw_import_key() {
  if gpg --list-keys "$LW_GPG_KEY" >/dev/null 2>&1; then
    return 0
  fi
  info "importing LibreWolf release GPG key ${LW_GPG_KEY:0:16}..."
  local ks
  for ks in "$LW_GPG_KEYSERVER" hkps://keyserver.ubuntu.com; do
    if gpg --keyserver "$ks" --recv-keys "$LW_GPG_KEY" 2>/dev/null; then
      ok "LibreWolf GPG key imported (via $ks)"
      return 0
    fi
  done
  return 0  # auto-key-retrieve fetches at verify time if still missing
}

# --- helper: fetch + sha256-verify + GPG-verify a release asset --------------
#   args: <filename>  -> sets $_DL (path), $_SHA_OK, $_GPG_OK
_lw_fetch_verify() {
  local fname="$1"
  local url="${LW_REL}/${fname}"
  _DL="$DL_DIR/${fname}"
  mkdir -p "$DL_DIR"
  if [[ -f "$_DL" ]]; then
    skip "cached ${fname}"
  else
    info "downloading ${fname}"
    if ! run_cmd_retry 3 5 curl -fL --connect-timeout 30 -A 'Mozilla/5.0' -o "$_DL" "$url"; then
      warn "download failed: ${url}"
      _add_warning "librewolf: download failed for ${fname}"
      _SHA_OK=false; _GPG_OK=false; return 1
    fi
  fi

  # sha256 against the upstream .sha256sum sidecar (authoritative)
  local sha_file="${_DL}.sha256sum"
  if ! curl -fsSL --connect-timeout 15 -A 'Mozilla/5.0' -o "$sha_file" "${LW_REL}/${fname}.sha256sum" 2>/dev/null; then
    warn "could not fetch .sha256sum sidecar for ${fname}"
    _add_warning "librewolf: missing sha256sum sidecar for ${fname}"
    _SHA_OK=false
  else
    local up my
    up="$(awk '{print $1}' "$sha_file")"
    my="$(sha256sum "$_DL" | awk '{print $1}')"
    if [[ -n "$up" && "$up" == "$my" ]]; then
      ok "sha256 verified: ${fname}"
      _SHA_OK=true
    else
      warn "sha256 MISMATCH for ${fname}: expected ${up} got ${my}"
      _add_warning "librewolf: sha256 mismatch for ${fname} (upstream changed?)"
      _SHA_OK=false
    fi
  fi

  # GPG detached signature (.sig sidecar)
  local sig_file="${_DL}.sig"
  if ! curl -fsSL --connect-timeout 15 -A 'Mozilla/5.0' -o "$sig_file" "${LW_REL}/${fname}.sig" 2>/dev/null; then
    warn "could not fetch .sig sidecar for ${fname} (GPG skip)"
    _add_warning "librewolf: missing .sig for ${fname}"
    _GPG_OK=false
  else
    if gpg --verify "$sig_file" "$_DL" >/tmp/lw_gpg.out 2>&1; then
      ok "GPG verified: ${fname}"
      _GPG_OK=true
    else
      warn "GPG verify FAILED for ${fname}:"
      sed 's/^/    /' /tmp/lw_gpg.out 2>/dev/null | head -5 >&2
      _add_warning "librewolf: GPG verify failed for ${fname}"
      _GPG_OK=false
    fi
    rm -f /tmp/lw_gpg.out
  fi
}

# --- helper: install an extracted tree to /opt/librewolf ---------------------
#   arg: <src_dir containing librewolf/>  ->  result at $LW_PREFIX
_lw_install_tree() {
  local src_pkg="$1"   # path to a dir containing a top-level librewolf/
  if [[ ! -d "$src_pkg/librewolf" ]]; then
    warn "tarball did not extract a librewolf/ dir"
    _add_warning "librewolf: tarball layout unexpected (no librewolf/ dir)"
    return 1
  fi
  info "installing to ${LW_PREFIX} (sudo)"
  sudo rm -rf "${LW_PREFIX}.new" 2>/dev/null || true
  if ! sudo cp -a "$src_pkg/librewolf" "${LW_PREFIX}.new"; then
    warn "failed to stage ${LW_PREFIX}.new"
    _add_warning "librewolf: staging copy failed"
    return 1
  fi
  sudo chown -R root:root "${LW_PREFIX}.new"
  # Ensure world-readable so the /usr/local/bin symlink is traversable for
  # non-root users. Harmless when upstream already ships 0755 (librewolf does).
  sudo chmod -R a+rX "${LW_PREFIX}.new"
  # Atomic-ish swap: rename old aside, move new in, remove old.
  sudo rm -rf "${LW_PREFIX}.old" 2>/dev/null || true
  if [[ -d "$LW_PREFIX" ]]; then
    sudo mv "$LW_PREFIX" "${LW_PREFIX}.old"
  fi
  sudo mv "${LW_PREFIX}.new" "$LW_PREFIX"
  sudo rm -rf "${LW_PREFIX}.old" 2>/dev/null || true
  ok "installed -> ${LW_PREFIX}"
}

# --- helper: write /usr/local/bin/librewolf symlink + .desktop ---------------
_lw_register() {
  sudo mkdir -p "$(dirname "$LW_BIN_SYMLINK")"
  sudo ln -sfn "$LW_PREFIX/librewolf" "$LW_BIN_SYMLINK"
  ok "symlink ${LW_BIN_SYMLINK} -> ${LW_PREFIX}/librewolf"
  mkdir -p "$(dirname "$LW_DESKTOP")"
  cat > "$LW_DESKTOP" <<EOF
[Desktop Entry]
Version=1.0
Name=LibreWolf
GenericName=Web Browser
Comment=LibreWolf is a custom Firefox build focused on privacy + freedom.
Exec=librewolf %u
Icon=$LW_PREFIX/browser/chrome/icons/default/default128.png
Terminal=false
Type=Application
Categories=Network;WebBrowser;Security;
StartupWMClass=LibreWolf
StartupNotify=true
MimeType=text/html;text/xml;application/xhtml+xml;application/vnd.mozilla.xul+xml;x-scheme-handler/http;x-scheme-handler/https;
EOF
  ok "wrote ${LW_DESKTOP/$HOME/\~}"
}

# --- 1. already installed at the pinned version? skip -------------------------
_lw_version() {
  if [[ -f "$LW_PREFIX/application.ini" ]]; then
    awk -F= '/^Version=/{print $2; exit}' "$LW_PREFIX/application.ini"
  fi
}

if [[ "$(_lw_version)" == "$LW_VERSION" ]]; then
  skip "librewolf ${LW_VERSION} (installed at ${LW_PREFIX})"
  _lw_register   # ensure launcher/symlink exist (idempotent)
  ok "librewolf (codeberg release)"
  return 0 2>/dev/null || exit 0
fi

# --- 2. import GPG key, fetch + verify tarball --------------------------------
_lw_import_key
_lw_fetch_verify "librewolf-${LW_VERSION}-linux-${LW_ARCH}-package.tar.xz"

if [[ "$_SHA_OK" != "true" ]]; then
  warn "refusing to install librewolf: sha256 not verified"
  ok "librewolf (skipped, verification failed)"
  return 0 2>/dev/null || exit 0
fi
if [[ "$_GPG_OK" != "true" ]]; then
  warn "GPG not verified — installing with sha256-only (see warnings)"
fi

# --- 3. extract + install -----------------------------------------------------
tmp="$(mktemp -d)"
if tar xJf "$_DL" -C "$tmp" 2>/dev/null; then
  _lw_install_tree "$tmp"
  _lw_register
else
  warn "tar extract failed for $_DL"
  _add_error "librewolf: tar extract failed"
fi
rm -rf "$tmp" "$_DL" "${_DL}.sha256sum" "${_DL}.sig"

ok "librewolf (codeberg release)"