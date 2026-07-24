# 000553-gcx.sh -- Grafana gcx CLI (official prebuilt binary, dual-arch)
# Installs:        none (pacman) -- downloads Grafana's official gcx release
# Links:           --
# Enables:         --
# Note: gcx (https://github.com/grafana/gcx) is Grafana's official CLI for
#       agentic/terminal access to a Grafana instance (dashboards, alerts,
#       SLOs, metrics, logs). Works with Grafana Cloud, Enterprise, AND OSS
#       self-hosted (Grafana 12+). We run self-hosted OSS Grafana in a PVE
#       container, so this is the tool we use to manage dashboards via the
#       HTTP API (instead of file-provisioning which is unreliable in
#       Grafana v13 unified storage). gcx ships as a single statically-linked
#       Go ELF per platform, with a per-release checksums.txt. We pin both
#       linux_amd64 (workstation) + linux_arm64 (raspberrypi) sha256s, both
#       computed by personally downloading the v0.4.4 assets and matching the
#       upstream-published checksums (NOT trusting the install.sh pipe).
#       Installing to ~/.local/bin/gcx as a real file (NOT a repo symlink --
#       it is a downloaded blob, not tracked source), mirroring proton-drive.
#       The roll-forward block uses the GitHub releases API for the latest tag
#       + the per-release checksums.txt, so the binary auto-advances without
#       re-pinning as long as upstream keeps publishing checksums. The
#       interactive `gcx login` is deferred to setup.sh (needs a Grafana
#       service-account token, which is a per-environment secret).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "gcx (grafana cli)"

GCX_VERSION="0.4.4"
GCX_REPO="grafana/gcx"
GCX_BASE="https://github.com/${GCX_REPO}/releases/download/v${GCX_VERSION}"

# --- per-arch pinned sha256 (personally verified against upstream
#     gcx_0.4.4_checksums.txt on 2026-07-17) -------------------------------------
# linux_amd64 -> 3c502999b8132fa4c426af5a9a15b3fc5c879b9a10d0decbb35ac74b713279f1
# linux_arm64 -> 455a9df73bce901a629cf8843e52e081169b13b79f0063918093d8363197d1c5
declare -A GCX_SHA256=(
  ["amd64"]="3c502999b8132fa4c426af5a9a15b3fc5c879b9a10d0decbb35ac74b713279f1"
  ["arm64"]="455a9df73bce901a629cf8843e52e081169b13b79f0063918093d8363197d1c5"
)

GCX_BIN="$HOME/.local/bin/gcx"
DL_DIR="$HOME/.cache/dotfiles-downloads"

# --- detect arch (matches gcx's own install.sh map: x86_64/amd64 -> amd64,
#     aarch64/arm64 -> arm64) ---------------------------------------------------
arch="$(uname -m)"
case "$arch" in
  x86_64|amd64) arch=amd64 ;;
  aarch64|arm64) arch=arm64 ;;
  *)
    warn "gcx: unsupported arch '$arch' — skipping (only amd64/arm64 pinned)"
    _add_warning "gcx: unsupported arch $arch (skipped)"
    ok "gcx (skipped, unsupported arch $arch)"
    exit 0  # nb: _common.sh is sourced, not exec'd; 'return' would error
    ;;
esac

# --- install the pinned binary -------------------------------------------------
# Skip if an executable is already present AND reports the pinned version.
already=false
if [[ -x "$GCX_BIN" ]]; then
  ver_out="$(cd / && "$GCX_BIN" --version 2>/dev/null | head -1)"
  if [[ "$ver_out" == *"$GCX_VERSION "* ]]; then
    skip "gcx ($GCX_VERSION, installed at ${GCX_BIN/$HOME/\~})"
    already=true
  fi
fi

if [[ "$already" == "false" ]]; then
  archive="gcx_${GCX_VERSION}_linux_${arch}.tar.gz"
  url="${GCX_BASE}/${archive}"
  DL_FILE="$DL_DIR/${archive}"
  mkdir -p "$DL_DIR"
  info "downloading gcx $GCX_VERSION ($arch) from $url"
  if run_cmd_retry 3 5 curl -fL --connect-timeout 30 -o "$DL_FILE" "$url"; then
    actual_sha="$(sha256sum "$DL_FILE" | awk '{print $1}')"
    if [[ "$actual_sha" != "${GCX_SHA256[$arch]}" ]]; then
      warn "gcx $arch tarball sha256 mismatch:"
      warn "  expected ${GCX_SHA256[$arch]}"
      warn "  got      $actual_sha"
      warn "upstream likely shipped a new build -- re-pin GCX_SHA256[$arch]"
      warn "in this migration after verifying the new asset."
      _add_warning "gcx: $arch sha mismatch (upstream changed) -- re-pin GCX_SHA256[$arch]"
      DL_FILE=""
    else
      ok "gcx $arch tarball sha256 verified"
    fi
  else
    warn "download failed for $url"
    _add_warning "gcx: download failed for $url"
    DL_FILE=""
  fi

  if [[ -n "$DL_FILE" && -s "$DL_FILE" ]]; then
    tmp="$(mktemp -d)"
    if tar xzf "$DL_FILE" -C "$tmp" gcx 2>/dev/null && [[ -x "$tmp/gcx" ]]; then
      mkdir -p "$HOME/.local/bin"
      if install -m755 "$tmp/gcx" "$GCX_BIN"; then
        ok "gcx installed -> ${GCX_BIN/$HOME/\~}"
      else
        warn "failed to install gcx binary"
        _add_warning "gcx: binary install failed"
      fi
    else
      warn "failed to extract gcx from $DL_FILE"
      _add_warning "gcx: tar extract failed"
    fi
    rm -rf "$tmp"
  fi

  rm -f "$DL_FILE"
fi

# --- shell completions (idempotent) --------------------------------------------
# gcx completion writes to standard locations. Skip if fish not installed.
if [[ -x "$GCX_BIN" ]]; then
  # fish
  if command -v fish >/dev/null 2>&1; then
    fish_comp_dir="$HOME/.config/fish/completions"
    mkdir -p "$fish_comp_dir"
    fish_comp="$fish_comp_dir/gcx.fish"
    if "$GCX_BIN" completion fish >"$fish_comp" 2>/dev/null; then
      ok "gcx fish completion -> ${fish_comp/$HOME/\~}"
    else
      warn "gcx fish completion failed (non-fatal)"
    fi
  fi
  # bash
  if [[ -d "$HOME/.local/share/bash-completion/completions" ]] || [[ -d "/usr/share/bash-completion/completions" ]]; then
    bash_comp_dir="$HOME/.local/share/bash-completion/completions"
    mkdir -p "$bash_comp_dir"
    if "$GCX_BIN" completion bash >"$bash_comp_dir/gcx" 2>/dev/null; then
      ok "gcx bash completion -> ${bash_comp_dir/$HOME/\~}/gcx"
    fi
  fi
fi

# --- roll forward to upstream latest release -----------------------------------
# Uses the GitHub releases API for the latest tag + the per-release
# checksums.txt (upstream publishes one for every release). Downloads the
# tarball, verifies against the UPSTREAM-published sha (not a hardcoded pin),
# and installs if newer. Non-fatal on any failure -- the pinned binary stays.
# This makes the migration "install-pinned-if-absent, else roll-to-upstream-
# latest" (idempotent on every migrate run), mirroring proton-drive.
if [[ -x "$GCX_BIN" ]]; then
  # Fetch the latest-release JSON to a temp file FIRST, then parse it.
  # The previous inline `curl ... | grep -m1 | sed` pipe raced: grep -m1
  # closes curl's stdout after the first match, curl gets SIGPIPE and exits
  # 23, and under `set -o pipefail` that aborts the whole migration (the
  # exit-23 failure seen in migrate logs). Capturing to a file first breaks
  # the pipe so curl runs to completion, matching the install_nix fix.
  _gcx_latest_json="$(mktemp)"
  curl -fsSL --connect-timeout 15 "https://api.github.com/repos/${GCX_REPO}/releases/latest" >"$_gcx_latest_json" 2>/dev/null || true
  latest="$(grep -m1 '"tag_name"' "$_gcx_latest_json" | sed 's/.*"tag_name": *"//;s/".*//')"
  rm -f "$_gcx_latest_json"
  latest="${latest#v}"
  inst="$(cd / && "$GCX_BIN" --version 2>/dev/null | head -1)"
  inst="${inst#*version }"; inst="${inst%% *}"
  if [[ -z "$latest" ]]; then
    warn "could not fetch gcx latest release (offline/rate-limit?) — keeping $inst"
    _add_warning "gcx: latest-release fetch failed (kept $inst)"
  elif [[ -z "$inst" || "$(vercmp "$latest" "$inst")" -gt 0 ]]; then
    up_base="https://github.com/${GCX_REPO}/releases/download/v${latest}"
    up_archive="gcx_${latest}_linux_${arch}.tar.gz"
    up_url="${up_base}/${up_archive}"
    up_sums_url="${up_base}/gcx_${latest}_checksums.txt"
    tmp="$(mktemp -d)"
    info "gcx ${inst:-<unknown>} -> $latest ($arch)"
    if curl -fsSL --connect-timeout 30 "$up_url" -o "$tmp/$up_archive" 2>/dev/null \
       && curl -fsSL --connect-timeout 15 "$up_sums_url" -o "$tmp/checksums.txt" 2>/dev/null; then
      up_expected="$(grep "${up_archive}" "$tmp/checksums.txt" | awk '{print $1}')"
      up_actual="$(sha256sum "$tmp/$up_archive" | awk '{print $1}')"
      if [[ -z "$up_expected" ]]; then
        warn "gcx $latest: $up_archive not in checksums.txt — not installing (kept $inst)"
        _add_warning "gcx: $latest missing from checksums.txt (kept $inst)"
      elif [[ "$up_actual" == "$up_expected" ]]; then
        if tar xzf "$tmp/$up_archive" -C "$tmp" gcx 2>/dev/null && install -m755 "$tmp/gcx" "$GCX_BIN" 2>/dev/null; then
          ok "gcx rolled forward to $latest"
          if command -v fish >/dev/null 2>&1; then
            "$GCX_BIN" completion fish >"$HOME/.config/fish/completions/gcx.fish" 2>/dev/null || true
          fi
        else
          warn "gcx $latest install failed — keeping $inst"
          _add_warning "gcx: $latest install failed (kept $inst)"
        fi
      else
        warn "gcx $latest sha mismatch — not installing (kept $inst)"
        _add_warning "gcx: $latest sha mismatch (kept $inst)"
      fi
    else
      warn "gcx $latest download failed — keeping $inst"
      _add_warning "gcx: $latest download failed (kept $inst)"
    fi
    rm -rf "$tmp"
  else
    skip "gcx $inst (upstream latest $latest)"
  fi
fi

ok "gcx (grafana cli)"