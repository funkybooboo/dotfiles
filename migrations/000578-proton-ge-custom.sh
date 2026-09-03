# 000578-proton-ge-custom.sh -- GE-Proton (GloriousEggroll custom Proton for native Steam)
# Installs:        none (pacman) -- downloads the GE-Proton release tarball
#                  from upstream GitHub releases into Steam's
#                  compatibilitytools.d (Tier 2 upstream release asset)
# Links:           --
# Enables:         --
# Note: GE-Proton (https://github.com/GloriousEggroll/proton-ge-custom) is a
#       custom Proton build for running Windows games under Steam (extra
#       media-foundation patches, FSR fullscreen hack, NVAPI/CUDA, per-game
#       "protonfixes", NTSync when the ntsync kernel module is loaded -- the
#       hardened kernel ships the module but does not auto-load it, and that
#       is a separate concern not managed here). Upstream's README lists
#       several install methods; the choice for this machine:
#         - Native manual (USED HERE): extract the release tarball into
#           ~/.steam/steam/compatibilitytools.d. Native pacman steam (000510)
#           symlinks ~/.steam/steam -> ~/.local/share/Steam after first
#           launch, so that path and ~/.local/share/Steam are the same place.
#         - Flathub com.valvesoftware.Steam.CompatibilityTool.Proton-GE and
#           the flatpak/snap compat dirs: NOT applicable (steam is the pacman
#           build) -- and the flathub build is unofficial and explicitly
#           unsupported by GloriousEggroll.
#         - asdf-protonge / ProtonPlus: third-party version managers,
#           redundant with this migration (and asdf is not used here; runtimes
#           are managed by mise, 000202).
#         - Build from source: pointless -- upstream publishes prebuilt
#           per-arch tarballs (GE-ProtonV-N-x86_64.tar.gz).
#       The tarball is verified against the upstream-published
#       <name>.sha512sum -- the same check upstream's own install script
#       performs (GE publishes no GPG signatures for release assets).
#       Roll-forward: every migrate run queries the GitHub API for the latest
#       release and installs it when absent, so GE-Proton advances with the
#       rest of the stack. Older GE-Proton* dirs are deliberately NEVER
#       pruned: Steam's per-game compatibility pin references the directory
#       name, so deleting an old version breaks games pinned to it (~450 MB
#       each; prune by hand if disk-pressured). A half-extracted dir from an
#       interrupted run is detected by its missing proton/version files and
#       reinstalled. Enabling the tool stays manual per upstream docs:
#       restart Steam, then per game Properties -> Compatibility -> "Force the
#       use of a specific Steam Play compatibility tool".

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "proton-ge-custom (GE-Proton)"

PGEC_REPO="GloriousEggroll/proton-ge-custom"
DL_DIR="$HOME/.cache/dotfiles-downloads"

# --- steam must be installed (000510 owns it and runs before this migration) ---
# 'exit 0' ends only this migration: _common.sh is sourced, not exec'd, and
# migrate.sh runs each migration in an isolated subshell (same idiom as 000553).
if ! pacman -Q steam >/dev/null 2>&1; then
  skip "proton-ge-custom (steam not installed -- 000510 owns it)"
  exit 0
fi

# --- resolve the Steam data root (native steam) -------------------------------
# After first launch, native steam symlinks ~/.steam/steam -> ~/.local/share/
# Steam (the real data root). Honor whichever exists; if steam was installed
# but never launched, install into the canonical real path -- upstream's
# manual steps likewise mkdir the compat dir before any launch.
if [[ -d "$HOME/.steam/steam" ]]; then
  steam_root="$HOME/.steam/steam"
elif [[ -d "$HOME/.local/share/Steam" ]]; then
  steam_root="$HOME/.local/share/Steam"
else
  steam_root="$HOME/.local/share/Steam"
  info "steam not launched yet -- using canonical data root ${steam_root/$HOME/\~}"
fi
compat_dir="$steam_root/compatibilitytools.d"

# --- arch: upstream ships per-arch tarballs (x86_64 / aarch64) -----------------
arch="$(uname -m)"
case "$arch" in
  x86_64)  suffix="x86_64" ;;
  aarch64) suffix="aarch64" ;;
  *)
    warn "proton-ge-custom: unsupported arch '$arch' -- skipping"
    _add_warning "proton-ge-custom: unsupported arch $arch (skipped)"
    exit 0
    ;;
esac

# --- latest release info from the GitHub API ----------------------------------
# Capture the JSON to a temp file FIRST: piping curl straight into grep races
# under pipefail (grep -m closes early -> curl gets SIGPIPE -> exit 23 aborts
# the migration). Same fix as the gcx roll-forward block in 000553.
json="$(mktemp)"
curl -fsSL --connect-timeout 15 \
  "https://api.github.com/repos/${PGEC_REPO}/releases/latest" >"$json" 2>/dev/null || true
if ! grep -q '"tag_name"' "$json" 2>/dev/null; then
  warn "could not fetch latest GE-Proton release (offline/rate-limit?) -- skipping"
  _add_warning "proton-ge-custom: latest-release fetch failed (skipped)"
  rm -f "$json"
  exit 0
fi
# api.github.com serves the SAME payload pretty-printed or compact (one
# single line, depending on which cache tier answers -- observed live during
# testing), so line-oriented grep/cut parsing alone is not reliable: on the
# compact form cut -f4 yields the wrong field and the asset filter misses.
# Split on commas first so every "browser_download_url":"..." pair lands on
# its own line in both shapes (URLs never contain commas), then extract as
# upstream's own script does. Fails closed (empty -> skip) on any surprise.
tarball_url="$(tr ',' '\n' <"$json" | grep browser_download_url | cut -d\" -f4 | grep -E -- "-${suffix}\.tar\.gz$" | head -n1 || true)"
sums_url="$(tr ',' '\n' <"$json" | grep browser_download_url | cut -d\" -f4 | grep -E -- "-${suffix}\.sha512sum$" | head -n1 || true)"
rm -f "$json"

if [[ -z "$tarball_url" || -z "$sums_url" ]]; then
  warn "latest release lacks a $suffix tarball + sha512sum asset pair -- skipping"
  _add_warning "proton-ge-custom: missing $suffix assets in latest release (skipped)"
  exit 0
fi

tarball_name="$(basename "$tarball_url")"
release_name="${tarball_name%.tar.gz}"   # == the top-level dir inside the tarball

# --- already installed (complete)? then skip ----------------------------------
if [[ -d "$compat_dir/$release_name" ]] \
   && [[ -f "$compat_dir/$release_name/proton" ]] \
   && [[ -f "$compat_dir/$release_name/version" ]]; then
  skip "proton-ge-custom $release_name (installed)"
  exit 0
fi

# Half-extracted dir from an interrupted run -- remove and redo.
if [[ -d "$compat_dir/$release_name" ]]; then
  info "removing incomplete $release_name (no proton/version files)"
  rm -rf "$compat_dir/$release_name"
fi

# --- download + sha512-verify + extract ----------------------------------------
mkdir -p "$compat_dir" "$DL_DIR"
DL_FILE="$DL_DIR/$tarball_name"
info "downloading $tarball_name"
if run_cmd_retry 3 5 curl -fL --connect-timeout 30 -o "$DL_FILE" "$tarball_url" \
   && run_cmd_retry 3 5 curl -fsSL --connect-timeout 15 -o "$DL_FILE.sha512sum" "$sums_url"; then
  expected="$(awk '{print $1}' "$DL_FILE.sha512sum")"
  actual="$(sha512sum "$DL_FILE" | awk '{print $1}')"
  if [[ -z "$expected" || "$actual" != "$expected" ]]; then
    warn "sha512 mismatch for $tarball_name -- not installing"
    _add_warning "proton-ge-custom: sha512 mismatch for $tarball_name (skipped)"
  else
    ok "$tarball_name sha512 verified"
    # Structural sanity: the first entry must be the single expected top-level
    # dir (the tarball is trusted via the checksum, but this also catches an
    # upstream asset-name/dir-name split drifting apart).
    first_entry="$(tar tzf "$DL_FILE" 2>/dev/null | head -n1 || true)"
    if [[ "$first_entry" != "$release_name/" ]]; then
      warn "unexpected tarball top entry '${first_entry:-<empty>}' -- not installing"
      _add_warning "proton-ge-custom: unexpected tarball structure (skipped)"
    elif tar xzf "$DL_FILE" -C "$compat_dir"; then
      if [[ -f "$compat_dir/$release_name/proton" && -f "$compat_dir/$release_name/version" ]]; then
        ok "GE-Proton $release_name -> ${compat_dir/$HOME/\~}/$release_name"
        info "restart Steam, then per game: Properties -> Compatibility ->"
        info "\"Force the use of a specific Steam Play compatibility tool\""
      else
        warn "extracted $release_name incomplete (no proton/version) -- removed"
        _add_warning "proton-ge-custom: $release_name extracted incomplete (removed)"
        rm -rf "$compat_dir/$release_name"
      fi
    else
      warn "tar extract failed for $tarball_name"
      _add_warning "proton-ge-custom: tar extract failed for $tarball_name"
      rm -rf "$compat_dir/$release_name"
    fi
  fi
else
  warn "download failed for $tarball_name -- skipping"
  _add_warning "proton-ge-custom: download failed for $tarball_name (skipped)"
fi
rm -f "$DL_FILE" "$DL_FILE.sha512sum"