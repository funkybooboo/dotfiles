# 000551-proton-drive.sh -- Proton Drive CLI (official prebuilt binary)
# Installs:        none (pacman) -- downloads Proton's official prebuilt binary
# Downloads:       https://proton.me/download/drive/cli/0.4.6/linux-x64/proton-drive
# Links:           --
# Enables:         --
# Note: Proton Drive has NO official Arch/AUR or Flatpak package; the only
#       supported Linux distribution is this single prebuilt ELF from
#       proton.me (dynamically linked, needs only glibc). It is a fetched,
#       verified artifact placed as a real file at ~/.local/bin/proton-drive
#       (NOT a repo symlink -- it is a downloaded blob, not tracked source),
#       mirroring the minecraft-launcher approach. The URL embeds the version
#       so we pin the sha256 to detect an upstream swap. The interactive
#       `auth login` is deferred to setup.sh (needs a browser). No shell
#       completions ship with the CLI (the `completions` subcommand is absent),
#       so none are generated here.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "proton drive cli"

PD_VERSION="0.4.6"
PD_URL="https://proton.me/download/drive/cli/${PD_VERSION}/linux-x64/proton-drive"
# Pinned sha256 of the 0.4.6 linux-x64 binary. If Proton replaces the asset,
# this checksum will no longer match and the install branch is skipped with a
# warning so the maintainer can re-pin (rather than silently swapping the
# binary).
PD_SHA256="89a54131a0811e42ea18ec43073d6eb347d80f594ed0226009bb94118f4cda86"

PD_BIN="$HOME/.local/bin/proton-drive"
DL_DIR="$HOME/.cache/dotfiles-downloads"
DL_FILE="$DL_DIR/proton-drive-${PD_VERSION}"

# --- install the CLI binary ------------------------------------------------------
# Skip if an executable is already present AND reports the pinned version.
# (`proton-drive --version` prints e.g. "Proton Drive CLI cli-drive@0.4.6+21156f23".)
already=false
if [[ -x "$PD_BIN" ]]; then
  ver_out="$(cd / && "$PD_BIN" --version 2>/dev/null | head -1)"
  if [[ "$ver_out" == *"$PD_VERSION"* ]]; then
    skip "proton-drive ($PD_VERSION, installed at ${PD_BIN/$HOME/\~})"
    already=true
  fi
fi

if [[ "$already" == "false" ]]; then
  mkdir -p "$DL_DIR"
  info "downloading Proton Drive CLI $PD_VERSION from $PD_URL"
  if run_cmd_retry 3 5 curl -fL --connect-timeout 30 -o "$DL_FILE" "$PD_URL"; then
    : # downloaded
  else
    warn "download failed for $PD_URL"
    _add_warning "proton-drive: download failed for $PD_URL"
    DL_FILE=""
  fi

  if [[ -n "$DL_FILE" && -s "$DL_FILE" ]]; then
    actual_sha="$(sha256sum "$DL_FILE" | awk '{print $1}')"
    if [[ "$actual_sha" != "$PD_SHA256" ]]; then
      warn "proton-drive binary sha256 mismatch:"
      warn "  expected $PD_SHA256"
      warn "  got      $actual_sha"
      warn "upstream likely shipped a new build -- re-pin PD_SHA256 in this"
      warn "migration after verifying the new asset."
      _add_warning "proton-drive: binary sha mismatch (upstream changed) -- re-pin PD_SHA256"
      DL_FILE=""
    else
      ok "proton-drive binary sha256 verified"
    fi
  fi

  if [[ -n "$DL_FILE" && -s "$DL_FILE" ]]; then
    mkdir -p "$HOME/.local/bin"
    if install -m755 "$DL_FILE" "$PD_BIN"; then
      ok "proton-drive installed -> ${PD_BIN/$HOME/\~}"
    else
      warn "failed to install proton-drive binary"
      _add_warning "proton-drive: binary install failed"
    fi
  fi

  rm -f "$DL_FILE"
fi

ok "proton drive cli"