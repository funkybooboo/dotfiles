# 000544-minecraft.sh -- Official Mojang Minecraft launcher (binary + desktop entry)
# Installs:        cargo/none -- downloads prebuilt launcher binary
# Downloads:       https://launcher.mojang.com/download/Minecraft.tar.gz
#                  https://launcher.mojang.com/download/minecraft-launcher.svg (committed, not fetched)
# Links:           ~/.local/bin/minecraft-launcher.sh (CEF-cache workaround wrapper)
#                  ~/.local/share/applications/minecraft-launcher.desktop
#                  ~/.local/share/icons/hicolor/symbolic/apps/minecraft-launcher.svg
# Enables:         --
# Note: The launcher binary is a fetched, verified artifact placed as a real
#       file at ~/.local/bin/minecraft-launcher (NOT a repo symlink -- it is
#       a downloaded blob, not tracked source). The tarball URL serves a rolling
#       "current" build; we pin its sha256 so an upstream swap is detected and
#       the maintainer is prompted to re-pin instead of silently replacing the
#       installed binary. The full-color SVG icon is committed to the repo
#       (its sha matches the AUR-pinned Mojang asset) and symlinked in.
#       The launcher self-updates its own game data under ~/.minecraft at
#       runtime, so the binary itself only rarely needs a re-pin.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "minecraft launcher"

MC_URL="https://launcher.mojang.com/download/Minecraft.tar.gz"
# Pinned sha256 of Minecraft.tar.gz (version 2.1.3, matches AUR pkgver
# 2.1.3-3). If Mojang replaces the rolling-current tarball, this checksum
# will no longer match and the install branch is skipped with a warning so
# the maintainer can re-pin (rather than silently swapping the binary).
MC_SHA256="695269281547bbbcf47fe74633027a0e4ddc13a61060c686a7217e85d314e45e"

MC_BIN="$HOME/.local/bin/minecraft-launcher"
DL_DIR="$HOME/.cache/dotfiles-downloads"
DL_TARBALL="$DL_DIR/Minecraft.tar.gz"

# --- install the launcher binary ------------------------------------------------
if [[ -x "$MC_BIN" ]]; then
  skip "minecraft-launcher (installed at $MC_BIN)"
else
  mkdir -p "$DL_DIR"
  info "downloading Minecraft launcher from $MC_URL"
  if run_cmd_retry 3 5 curl -fL --connect-timeout 30 -o "$DL_TARBALL" "$MC_URL"; then
    : # downloaded
  else
    warn "download failed for $MC_URL"
    _add_warning "minecraft: download failed for $MC_URL"
    DL_TARBALL=""
  fi

  if [[ -n "$DL_TARBALL" && -s "$DL_TARBALL" ]]; then
    actual_sha="$(sha256sum "$DL_TARBALL" | awk '{print $1}')"
    if [[ "$actual_sha" != "$MC_SHA256" ]]; then
      warn "minecraft tarball sha256 mismatch:"
      warn "  expected $MC_SHA256"
      warn "  got      $actual_sha"
      warn "upstream likely shipped a new build -- re-pin MC_SHA256 in this"
      warn "migration (and the SVG if it changed) after verifying the new asset."
      _add_warning "minecraft: tarball sha mismatch (upstream changed) -- re-pin MC_SHA256"
      DL_TARBALL=""
    else
      ok "minecraft tarball sha256 verified"
    fi
  fi

  if [[ -n "$DL_TARBALL" ]]; then
    tmp_extract="$(mktemp -d)"
    if tar -xzf "$DL_TARBALL" -C "$tmp_extract"; then
      mkdir -p "$HOME/.local/bin"
      if install -m755 "$tmp_extract/minecraft-launcher/minecraft-launcher" "$MC_BIN"; then
        ok "minecraft-launcher installed -> ${MC_BIN/$HOME/\~}"
      else
        warn "failed to install minecraft-launcher binary"
        _add_warning "minecraft: binary install failed"
      fi
    else
      warn "failed to extract $DL_TARBALL"
      _add_warning "minecraft: tar extraction failed"
    fi
    rm -rf "$tmp_extract"
  fi
fi

# --- link tracked configs (wrapper, desktop entry, icon) -------------------------
link_file "$DOTFILES_HOME/.local/bin/minecraft-launcher.sh" \
  "$HOME/.local/bin/minecraft-launcher.sh"
link_file "$DOTFILES_HOME/.local/share/applications/minecraft-launcher.desktop" \
  "$HOME/.local/share/applications/minecraft-launcher.desktop"
link_file "$DOTFILES_HOME/.local/share/icons/hicolor/symbolic/apps/minecraft-launcher.svg" \
  "$HOME/.local/share/icons/hicolor/symbolic/apps/minecraft-launcher.svg"

# Refresh desktop + icon caches so Hyprland menus pick up the new entry.
# Non-fatal: these tools may be absent on a minimal install.
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
fi
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache -f "$HOME/.local/share/icons/hicolor" 2>/dev/null || true
fi

ok "minecraft launcher"