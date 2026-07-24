# 000308-mullvad-browser.sh -- Mullvad Browser from upstream binary release (GitHub)
# Installs:        mullvad-browser (prebuilt binary tarball from GitHub releases)
# Installs to:     /opt/mullvad-browser  (binary tree extracted here, owned by root)
# Links:           /usr/local/bin/mullvad-browser -> /opt/mullvad-browser/Browser/start-mullvad-browser
#                  ~/.local/share/applications/mullvad-browser.desktop (written file)
# Enables:         --
# GPG verifies:    yes (Tor Browser Developers <torbrowser@torproject.org>,
#                  primary EF6E286DDA85EA2A4BA7DE684E2C6E8793298290)
# sha256 verifies: yes (against upstream-published sha256sums-signed-build.txt)
#
# Source: github.com/mullvad/mullvad-browser releases download 15.0.18 (latest).
#   Assets per release (linux):
#     mullvad-browser-linux-x86_64-<ver>.tar.xz        (~112 MB)
#     mullvad-browser-linux-x86_64-<ver>.tar.xz.asc    (GPG detached)
#     sha256sums-signed-build.txt                       (signed checksums for ALL assets)
#
# Policy: TIER 2 (upstream release asset). NO AUR, NO nix. Mullvad Browser is
#         a Tor-project-built, privacy-hardened Firefox that ships as a portable
#         self-contained tree (run-in-place, like Tor Browser). Installing to
#         /opt/mullvad-browser + symlink launcher mirrors the librewolf pattern.
#
# Idempotent: skips install if /opt/mullvad-browser/Browser/application.ini
#             reports the pinned version. Non-fatal.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "mullvad-browser (github release)"

MB_VERSION="15.0.18"
MB_REPO="mullvad/mullvad-browser"
MB_REL="https://github.com/${MB_REPO}/releases/download/${MB_VERSION}"
MB_ARCH="x86_64"

# Tor Project release signing key (signs mullvad-browser builds).
MB_GPG_KEY="EF6E286DDA85EA2A4BA7DE684E2C6E8793298290"
MB_GPG_KEYSERVER="hkps://keys.openpgp.org"

MB_PREFIX="/opt/mullvad-browser"
MB_BIN_SYMLINK="/usr/local/bin/mullvad-browser"
MB_DESKTOP="$HOME/.local/share/applications/mullvad-browser.desktop"
DL_DIR="$HOME/.cache/dotfiles-downloads"

# --- helpers (same shape as 000307-librewolf; kept self-contained so this
#     migration is independently runnable) -------------------------------------

# Best-effort: modern gpg auto-retrieves the key during --verify, so an import
# failure here does NOT block verification -- the verify step reports for real.
_mb_import_key() {
  if gpg --list-keys "$MB_GPG_KEY" >/dev/null 2>&1; then
    return 0
  fi
  info "importing Tor Browser release GPG key ${MB_GPG_KEY:0:16}..."
  local ks
  for ks in "$MB_GPG_KEYSERVER" hkps://keyserver.ubuntu.com; do
    if gpg --keyserver "$ks" --recv-keys "$MB_GPG_KEY" 2>/dev/null; then
      ok "Tor Browser GPG key imported (via $ks)"
      return 0
    fi
  done
  return 0  # auto-key-retrieve fetches at verify time if still missing
}

_mb_version() {
  if [[ -f "$MB_PREFIX/Browser/application.ini" ]]; then
    awk -F= '/^Version=/{print $2; exit}' "$MB_PREFIX/Browser/application.ini"
  fi
}

# --- 1. already installed at the pinned version? skip -------------------------
if [[ "$(_mb_version)" == "$MB_VERSION" ]]; then
  skip "mullvad-browser ${MB_VERSION} (installed at ${MB_PREFIX})"
  ok "mullvad-browser (github release)"
  return 0 2>/dev/null || exit 0
fi

# --- 2. fetch tarball + sha256sums + asc --------------------------------------
mkdir -p "$DL_DIR"
tarball="mullvad-browser-linux-${MB_ARCH}-${MB_VERSION}.tar.xz"
tar_url="${MB_REL}/${tarball}"
sha_url="${MB_REL}/sha256sums-signed-build.txt"
asc_url="${MB_REL}/${tarball}.asc"

DL="$DL_DIR/${tarball}"
SHA="$DL_DIR/mullvad-sha256sums-${MB_VERSION}.txt"
ASC="$DL_DIR/${tarball}.asc"

if [[ -f "$DL" ]]; then
  skip "cached ${tarball}"
else
  info "downloading ${tarball}"
  if ! run_cmd_retry 3 5 curl -fL --connect-timeout 30 -A 'Mozilla/5.0' -o "$DL" "$tar_url"; then
    warn "download failed: ${tar_url}"
    _add_warning "mullvad: download failed for ${tarball}"
    ok "mullvad-browser (skipped, download failed)"
    return 0 2>/dev/null || exit 0
  fi
fi
if [[ -f "$SHA" ]]; then
  skip "cached sha256sums"
else
  info "downloading sha256sums-signed-build.txt"
  curl -fsSL --connect-timeout 15 -A 'Mozilla/5.0' -o "$SHA" "$sha_url" 2>/dev/null || true
fi
if [[ -f "$ASC" ]]; then
  skip "cached .asc"
else
  curl -fsSL --connect-timeout 15 -A 'Mozilla/5.0' -o "$ASC" "$asc_url" 2>/dev/null || true
fi

# --- 3. sha256 verify against the signed-build checksums file -----------------
sha_ok=false
if [[ -s "$SHA" ]]; then
  up="$(grep -E "[[:space:]]+${tarball//\./\\.}\$" "$SHA" | awk '{print $1}' | head -1)"
  my="$(sha256sum "$DL" | awk '{print $1}')"
  if [[ -n "$up" && "$up" == "$my" ]]; then
    ok "sha256 verified: ${tarball}"
    sha_ok=true
  else
    warn "sha256 MISMATCH for ${tarball}: expected ${up} got ${my}"
    _add_warning "mullvad: sha256 mismatch for ${tarball} (upstream changed?)"
  fi
else
  warn "could not fetch sha256sums-signed-build.txt"
  _add_warning "mullvad: missing sha256sums file"
fi
if [[ "$sha_ok" != "true" ]]; then
  warn "refusing to install mullvad-browser: sha256 not verified"
  ok "mullvad-browser (skipped, verification failed)"
  return 0 2>/dev/null || exit 0
fi

# --- 4. GPG verify (best-effort; sha256 is authoritative) --------------------
_mb_import_key
if [[ -s "$ASC" ]]; then
  if gpg --verify "$ASC" "$DL" >/tmp/mb_gpg.out 2>&1; then
    ok "GPG verified: ${tarball}"
  else
    warn "GPG verify warning (non-fatal; sha256 already verified):"
    sed 's/^/    /' /tmp/mb_gpg.out 2>/dev/null | head -5 >&2
    _add_warning "mullvad: GPG verify warning (sha256 OK)"
  fi
  rm -f /tmp/mb_gpg.out
else
  warn ".asc not fetched — GPG skipped (sha256 verified)"
  _add_warning "mullvad: GPG skipped (no .asc)"
fi

# --- 5. extract + install to /opt/mullvad-browser ----------------------------
tmp="$(mktemp -d)"
if tar xJf "$DL" -C "$tmp" 2>/dev/null; then
  if [[ -d "$tmp/mullvad-browser" ]]; then
    info "installing to ${MB_PREFIX} (sudo)"
    sudo rm -rf "${MB_PREFIX}.new" 2>/dev/null || true
    sudo cp -a "$tmp/mullvad-browser" "${MB_PREFIX}.new"
    sudo chown -R root:root "${MB_PREFIX}.new"
    # Mullvad Browser ships as a portable, run-in-place tree (Tor-Browser style).
    # The upstream start-mullvad-browser launcher resolves its own paths at run
    # time, so we just drop the tree in /opt + symlink the launcher.
    sudo rm -rf "${MB_PREFIX}.old" 2>/dev/null || true
    if [[ -d "$MB_PREFIX" ]]; then
      sudo mv "$MB_PREFIX" "${MB_PREFIX}.old"
    fi
    sudo mv "${MB_PREFIX}.new" "$MB_PREFIX"
    sudo rm -rf "${MB_PREFIX}.old" 2>/dev/null || true
    ok "installed -> ${MB_PREFIX}"
    sudo mkdir -p "$(dirname "$MB_BIN_SYMLINK")"
    sudo ln -sfn "${MB_PREFIX}/Browser/start-mullvad-browser" "$MB_BIN_SYMLINK"
    ok "symlink ${MB_BIN_SYMLINK} -> ${MB_PREFIX}/Browser/start-mullvad-browser"
    mkdir -p "$(dirname "$MB_DESKTOP")"
    cat > "$MB_DESKTOP" <<EOF
[Desktop Entry]
Version=1.0
Name=Mullvad Browser
GenericName=Web Browser
Comment=Mullvad Browser is a privacy-focused Firefox build (Tor/Mullvad).
Exec=sh -c '"${MB_PREFIX}/Browser/start-mullvad-browser" --detach || "${MB_PREFIX}/Browser/start-mullvad-browser"' dummy %u
Icon=web-browser
Terminal=false
Type=Application
Categories=Network;WebBrowser;Security;
StartupWMClass=Mullvad Browser
StartupNotify=true
MimeType=text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;
EOF
    ok "wrote ${MB_DESKTOP/$HOME/\~}"
  else
    warn "tarball did not extract a mullvad-browser/ dir"
    _add_warning "mullvad: tarball layout unexpected"
  fi
else
  warn "tar extract failed for $DL"
  _add_error "mullvad: tar extract failed"
fi
rm -rf "$tmp" "$DL" "$ASC" "$SHA"

ok "mullvad-browser (github release)"