# 000602-retired-software.sh -- remove software retired by the
# 2026-11-27 demand audit (operator decision)
# Removes:  minecraft launcher (downloaded binary + tracked files)
#            weasis (flatpak DICOM viewer)
#            android-udev (+ adbusers membership)
# Enables:  --
# Note: the three install migrations (000083, 000544, 000587) are
#       DELETED from the tree -- git history holds them -- so fresh
#       machines never install the retired set. This migration exists
#       for machines that still carry it and removes it idempotently.
#       Data is deliberately NOT touched: the minecraft worlds stay
#       at ~/.minecraft, weasis flatpak data survives the uninstall
#       (no --delete-data), and no adb/fastboot state exists to lose.
#       The removals were named by the operator after a usage audit;
#       re-adding any of them means restoring its install migration
#       from git history.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "retired software (minecraft, weasis, android-udev)"

# --- minecraft launcher (downloaded binary; tracked wrapper/desktop/icon
#     links are removed with their repo files) -------------------------------
for f in "$HOME/.local/bin/minecraft-launcher" \
         "$HOME/.local/bin/minecraft-launcher.sh" \
         "$HOME/.local/share/applications/minecraft-launcher.desktop" \
         "$HOME/.local/share/icons/hicolor/symbolic/apps/minecraft-launcher.svg" \
         "$HOME/.cache/dotfiles-downloads/Minecraft.tar.gz"; do
  if [[ -e "$f" ]]; then
    rm -f "$f" && ok "removed ${f/$HOME/\~}"
  fi
done
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
fi

# --- weasis (flatpak) ---------------------------------------------------------
if flatpak info io.github.nroduit.Weasis >/dev/null 2>&1; then
  if flatpak uninstall -y --noninteractive io.github.nroduit.Weasis >/dev/null 2>&1; then
    ok "uninstalled flatpak io.github.nroduit.Weasis"
  else
    warn "flatpak uninstall failed for Weasis"
    _add_warning "weasis: flatpak uninstall failed (retry manually)"
  fi
else
  skip "weasis (not installed)"
fi

# --- android-udev + adbusers membership ----------------------------------------
remove_pkg android-udev
if groups "$USER" | grep -qw adbusers; then
  if sudo gpasswd -d "$USER" adbusers >/dev/null 2>&1; then
    ok "removed $USER from adbusers group"
  else
    warn "failed to remove $USER from adbusers"
    _add_warning "android-udev: gpasswd -d failed; remove manually"
  fi
else
  skip "adbusers membership (not a member)"
fi

ok "retired software removed"
